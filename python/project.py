import cv2
import face_recognition
import numpy as np
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import ttkbootstrap as ttkb
from ttkbootstrap.constants import *
from ttkbootstrap.tooltip import ToolTip
import os
import pickle
import requests
import threading
from PIL import Image, ImageTk
import json
import time
import logging
import re
from flask import Flask, request, jsonify
import tempfile
import shutil

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

class FaceRecognitionSystem:
    def __init__(self):
        self.root = ttkb.Window(themename="litera")
        self.root.title("Face Recognition Door Lock System")
        self.root.geometry("1000x700")
        
        # Node.js server settings
        self.nodejs_server_ip = "192.168.81.154"
        self.nodejs_server_port = 3001
        
        # Face recognition variables
        self.known_face_encodings = []
        self.known_face_names = []
        self.face_locations = []
        self.face_encodings = []
        
        # Camera
        self.video_capture = None
        self.camera_active = False
        self.recognition_active = False
        
        # Door lock timer
        self.lock_timer = None
        self.door_unlocked = False
        
        # GUI variables
        self.video_label = None
        self.status_label = None
        self.icon_cache = {}
        
        # Flask server for mobile uploads
        self.app = Flask(__name__)
        self.server_thread = None
        self.setup_flask_routes()
        
        self.setup_gui()
        self.load_known_faces()
        
    def load_icon(self, icon_path, size=(20, 20)):
        """Load and resize icon for buttons, return None if file is missing"""
        if icon_path not in self.icon_cache:
            if os.path.exists(icon_path):
                try:
                    img = Image.open(icon_path).resize(size, Image.LANCZOS)
                    self.icon_cache[icon_path] = ImageTk.PhotoImage(img)
                    logging.info(f"Loaded icon: {icon_path}")
                except Exception as e:
                    logging.error(f"Failed to load icon {icon_path}: {str(e)}")
                    self.icon_cache[icon_path] = None
            else:
                logging.warning(f"Icon file not found: {icon_path}")
                self.icon_cache[icon_path] = None
        return self.icon_cache[icon_path]
        
    def setup_gui(self):
        """Set up the GUI layout"""
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_columnconfigure(0, weight=0)
        self.root.grid_columnconfigure(1, weight=1)
        
        # Sidebar frame
        sidebar = ttkb.Frame(self.root, padding=10, bootstyle=SECONDARY)
        sidebar.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.W), padx=5, pady=5)
        sidebar.grid_rowconfigure(10, weight=1)
        
        # Main content frame
        main_frame = ttkb.Frame(self.root, padding=10)
        main_frame.grid(row=0, column=1, sticky=(tk.N, tk.S, tk.E, tk.W), padx=5, pady=5)
        main_frame.grid_rowconfigure(1, weight=1)
        main_frame.grid_columnconfigure(0, weight=1)
        
        # Title
        title_label = ttkb.Label(sidebar, text="Face Door Lock",
                                font=("Arial", 16, "bold"), bootstyle=INFO)
        title_label.pack(pady=10, fill=tk.X)
        
        # Node.js Server Configuration
        ip_frame = ttkb.LabelFrame(sidebar, text="Node.js Server Config", padding=5)
        ip_frame.pack(fill=tk.X, pady=5)
        
        ip_subframe = ttkb.Frame(ip_frame)
        ip_subframe.pack(fill=tk.X, padx=5, pady=5)
        
        ttkb.Label(ip_subframe, text="IP Address:").pack(side=tk.LEFT, padx=5)
        self.ip_entry = ttkb.Entry(ip_subframe, width=20)
        self.ip_entry.insert(0, self.nodejs_server_ip)
        self.ip_entry.pack(side=tk.LEFT, padx=5)
        
        test_btn = ttkb.Button(ip_frame, text="Test", bootstyle=INFO,
                              command=self.test_server_connection)
        test_icon = self.load_icon("icons/test.png")
        if test_icon:
            test_btn.configure(image=test_icon, compound=tk.LEFT)
        test_btn.pack(fill=tk.X, padx=5, pady=5)
        ToolTip(test_btn, text="Test connection to Node.js server")
        
        # Auto-lock Settings
        autolock_frame = ttkb.LabelFrame(sidebar, text="Auto-Lock", padding=5)
        autolock_frame.pack(fill=tk.X, pady=5)
        
        autolock_subframe = ttkb.Frame(autolock_frame)
        autolock_subframe.pack(fill=tk.X, padx=5, pady=5)
        ttkb.Label(autolock_subframe, text="Seconds:").pack(side=tk.LEFT, padx=5)
        self.autolock_var = tk.StringVar(value="10")
        autolock_spinbox = ttkb.Spinbox(autolock_subframe, from_=5, to=60, width=5,
                                        textvariable=self.autolock_var)
        autolock_spinbox.pack(side=tk.LEFT, padx=5)
        
        self.autolock_enabled = tk.BooleanVar(value=True)
        ttkb.Checkbutton(autolock_frame, text="Enable Auto-lock",
                        variable=self.autolock_enabled, bootstyle=INFO).pack(padx=5, pady=5)
        
        # Face Management
        face_frame = ttkb.LabelFrame(sidebar, text="Face Management", padding=5)
        face_frame.pack(fill=tk.X, pady=5)
        
        add_files_btn = ttkb.Button(face_frame, text="Add from Files", bootstyle=PRIMARY,
                                   command=self.add_faces_from_files)
        add_folder_icon = self.load_icon("icons/folder_add.png")
        if add_folder_icon:
            add_files_btn.configure(image=add_folder_icon, compound=tk.LEFT)
        add_files_btn.pack(fill=tk.X, padx=5, pady=2)
        
        view_btn = ttkb.Button(face_frame, text="View Faces", bootstyle=PRIMARY,
                              command=self.view_known_faces)
        view_icon = self.load_icon("icons/view.png")
        if view_icon:
            view_btn.configure(image=view_icon, compound=tk.LEFT)
        view_btn.pack(fill=tk.X, padx=5, pady=2)
        
        delete_btn = ttkb.Button(face_frame, text="Delete Face", bootstyle=PRIMARY,
                                command=self.delete_face)
        delete_icon = self.load_icon("icons/delete.png")
        if delete_icon:
            delete_btn.configure(image=delete_icon, compound=tk.LEFT)
        delete_btn.pack(fill=tk.X, padx=5, pady=2)
        
        # Mobile Upload Server Controls
        server_frame = ttkb.LabelFrame(sidebar, text="Mobile Upload Server", padding=5)
        server_frame.pack(fill=tk.X, pady=5)
        
        start_server_btn = ttkb.Button(server_frame, text="Start Server", bootstyle=SUCCESS,
                                      command=self.start_server)
        start_server_icon = self.load_icon("icons/server_start.png")
        if start_server_icon:
            start_server_btn.configure(image=start_server_icon, compound=tk.LEFT)
        start_server_btn.pack(fill=tk.X, padx=5, pady=2)
        ToolTip(start_server_btn, text="Start server to receive mobile uploads")
        
        stop_server_btn = ttkb.Button(server_frame, text="Stop Server", bootstyle=DANGER,
                                     command=self.stop_server)
        stop_server_icon = self.load_icon("icons/server_stop.png")
        if stop_server_icon:
            stop_server_btn.configure(image=stop_server_icon, compound=tk.LEFT)
        stop_server_btn.pack(fill=tk.X, padx=5, pady=2)
        ToolTip(stop_server_btn, text="Stop server for mobile uploads")
        
        # Door Control
        door_frame = ttkb.LabelFrame(sidebar, text="Door Control", padding=5)
        door_frame.pack(fill=tk.X, pady=5)
        
        unlock_btn = ttkb.Button(door_frame, text="Unlock", bootstyle=SUCCESS,
                                command=self.unlock_door)
        unlock_icon = self.load_icon("icons/unlock.png")
        if unlock_icon:
            unlock_btn.configure(image=unlock_icon, compound=tk.LEFT)
        unlock_btn.pack(fill=tk.X, padx=5, pady=2)
        
        lock_btn = ttkb.Button(door_frame, text="Lock", bootstyle=DANGER,
                              command=self.lock_door)
        lock_icon = self.load_icon("icons/lock.png")
        if lock_icon:
            lock_btn.configure(image=lock_icon, compound=tk.LEFT)
        lock_btn.pack(fill=tk.X, padx=5, pady=2)
        
        status_btn = ttkb.Button(door_frame, text="Check Status", bootstyle=INFO,
                                command=self.check_door_status)
        status_icon = self.load_icon("icons/status.png")
        if status_icon:
            status_btn.configure(image=status_icon, compound=tk.LEFT)
        status_btn.pack(fill=tk.X, padx=5, pady=2)
        
        cancel_btn = ttkb.Button(door_frame, text="Cancel Auto-lock", bootstyle=WARNING,
                                command=self.cancel_autolock)
        cancel_icon = self.load_icon("icons/cancel.png")
        if cancel_icon:
            cancel_btn.configure(image=cancel_icon, compound=tk.LEFT)
        cancel_btn.pack(fill=tk.X, padx=5, pady=2)
        
        # Status Frame
        status_frame = ttkb.LabelFrame(sidebar, text="Status", padding=5)
        status_frame.pack(fill=tk.X, pady=5, side=tk.BOTTOM)
        
        self.status_label = ttkb.Label(status_frame, text="Ready",
                                      font=("Arial", 12), bootstyle=INFO)
        self.status_label.pack(pady=5)
        
        self.timer_label = ttkb.Label(status_frame, text="",
                                     font=("Arial", 10), bootstyle=DANGER)
        self.timer_label.pack(pady=2)
        
        # Camera Frame
        camera_frame = ttkb.LabelFrame(main_frame, text="Camera Feed", padding=5)
        camera_frame.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.E, tk.W), pady=5)
        camera_frame.grid_rowconfigure(0, weight=1)
        camera_frame.grid_columnconfigure(0, weight=1)
        
        self.video_label = ttkb.Label(camera_frame, text="Camera feed will appear here",
                                     bootstyle=SECONDARY)
        self.video_label.grid(row=0, column=0, pady=10, sticky=(tk.N, tk.S, tk.E, tk.W))
        
        # Camera Controls
        camera_controls = ttkb.Frame(camera_frame)
        camera_controls.grid(row=1, column=0, pady=5, sticky=tk.E)
        
        start_cam_btn = ttkb.Button(camera_controls, text="Start Camera", bootstyle=SUCCESS,
                                   command=self.start_camera)
        start_cam_icon = self.load_icon("icons/camera_start.png")
        if start_cam_icon:
            start_cam_btn.configure(image=start_cam_icon, compound=tk.LEFT)
        start_cam_btn.pack(side=tk.LEFT, padx=5)
        
        stop_cam_btn = ttkb.Button(camera_controls, text="Stop Camera", bootstyle=DANGER,
                                  command=self.stop_camera)
        stop_cam_icon = self.load_icon("icons/camera_stop.png")
        if stop_cam_icon:
            stop_cam_btn.configure(image=stop_cam_icon, compound=tk.LEFT)
        stop_cam_btn.pack(side=tk.LEFT, padx=5)
        
        start_rec_btn = ttkb.Button(camera_controls, text="Start Recognition", bootstyle=PRIMARY,
                                   command=self.start_recognition)
        start_rec_icon = self.load_icon("icons/recognition_start.png")
        if start_rec_icon:
            start_rec_btn.configure(image=start_rec_icon, compound=tk.LEFT)
        start_rec_btn.pack(side=tk.LEFT, padx=5)
        
        stop_rec_btn = ttkb.Button(camera_controls, text="Stop Recognition", bootstyle=WARNING,
                                  command=self.stop_recognition)
        stop_rec_icon = self.load_icon("icons/recognition_stop.png")
        if stop_rec_icon:
            stop_rec_btn.configure(image=stop_rec_icon, compound=tk.LEFT)
        stop_rec_btn.pack(side=tk.LEFT, padx=5)
    
    def setup_flask_routes(self):
        """Set up Flask routes for receiving images from mobile app"""
        @self.app.route('/upload_face', methods=['POST'])
        def upload_face():
            try:
                if 'image' not in request.files or 'name' not in request.form:
                    return jsonify({"error": "Image and name are required"}), 400
                
                image_file = request.files['image']
                name = request.form['name'].strip()
                
                if not image_file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.tiff')):
                    return jsonify({"error": "Unsupported image format"}), 400
                
                temp_dir = tempfile.mkdtemp()
                temp_path = os.path.join(temp_dir, image_file.filename)
                image_file.save(temp_path)
                
                image = face_recognition.load_image_file(temp_path)
                face_encodings = face_recognition.face_encodings(image)
                
                if face_encodings:
                    if name not in self.known_face_names:
                        self.known_face_encodings.append(face_encodings[0])
                        self.known_face_names.append(name)
                        self.save_known_faces()
                        self.root.after(0, lambda: self.update_status(f"Added face from mobile: {name}", SUCCESS))
                        shutil.rmtree(temp_dir)
                        return jsonify({"message": f"Face for {name} added successfully"}), 200
                    else:
                        shutil.rmtree(temp_dir)
                        return jsonify({"error": f"Face for {name} already exists"}), 400
                else:
                    shutil.rmtree(temp_dir)
                    return jsonify({"error": "No face found in the image"}), 400
                
            except Exception as e:
                if 'temp_dir' in locals():
                    shutil.rmtree(temp_dir)
                self.root.after(0, lambda: self.update_status(f"Error adding face from mobile: {str(e)}", DANGER))
                logging.error(f"Error adding face from mobile: {str(e)}")
                return jsonify({"error": str(e)}), 500

    def start_server(self):
        """Start Flask server in a separate thread"""
        if self.server_thread is None:
            self.server_thread = threading.Thread(target=lambda: self.app.run(host='0.0.0.0', port=5000, debug=False))
            self.server_thread.daemon = True
            self.server_thread.start()
            self.update_status("Server started for mobile uploads at 0.0.0.0:5000", SUCCESS)
        else:
            self.update_status("Server is already running", WARNING)

    def stop_server(self):
        """Stop Flask server (simplified, actual stop requires more complex handling)"""
        if self.server_thread:
            self.server_thread = None
            self.update_status("Server stopped (restart required for new uploads)", INFO)
    
    def load_known_faces(self):
        """Load known faces from pickle file"""
        try:
            if os.path.exists("known_faces.pkl"):
                with open("known_faces.pkl", "rb") as f:
                    data = pickle.load(f)
                    self.known_face_encodings = data["encodings"]
                    self.known_face_names = data["names"]
                self.update_status(f"Loaded {len(self.known_face_names)} known faces", SUCCESS)
            else:
                self.update_status("No known faces file found", WARNING)
        except Exception as e:
            self.update_status(f"Error loading faces: {str(e)}", DANGER)
            logging.error(f"Error loading known faces: {str(e)}")
    
    def save_known_faces(self):
        """Save known faces to pickle file"""
        try:
            data = {
                "encodings": self.known_face_encodings,
                "names": self.known_face_names
            }
            with open("known_faces.pkl", "wb") as f:
                pickle.dump(data, f)
            self.update_status("Faces saved successfully", SUCCESS)
        except Exception as e:
            self.update_status(f"Error saving faces: {str(e)}", DANGER)
            logging.error(f"Error saving faces: {str(e)}")
    
    def add_faces_from_files(self):
        """Add faces from selected image files - supports PNG, JPG, JPEG, BMP, TIFF"""
        file_paths = filedialog.askopenfilenames(title="Select face images", 
                                               filetypes=[("Image files", "*.png *.jpg *.jpeg *.bmp *.tiff")])
        if not file_paths:
            return
        
        added_count = 0
        supported_formats = ('.png', '.jpg', '.jpeg', '.bmp', '.tiff')
        
        for image_path in file_paths:
            filename = os.path.basename(image_path)
            name = os.path.splitext(filename)[0]
            
            try:
                with Image.open(image_path) as img:
                    img.verify()
                image = face_recognition.load_image_file(image_path)
                face_encodings = face_recognition.face_encodings(image)
                
                if face_encodings:
                    if name not in self.known_face_names:
                        self.known_face_encodings.append(face_encodings[0])
                        self.known_face_names.append(name)
                        added_count += 1
                        self.update_status(f"Added face: {name}", SUCCESS)
                    else:
                        self.update_status(f"Face {name} already exists, skipping", WARNING)
                else:
                    self.update_status(f"No face found in {filename}", WARNING)
            except Exception as e:
                self.update_status(f"Error processing {filename}: {str(e)}", DANGER)
                logging.error(f"Error processing {filename}: {str(e)}")
                continue
        
        if added_count > 0:
            self.save_known_faces()
            messagebox.showinfo("Success", f"Added {added_count} new faces successfully!")
        else:
            messagebox.showinfo("Info", "No new faces were added")
    
    def delete_face(self):
        """Delete a known face"""
        if not self.known_face_names:
            messagebox.showinfo("Info", "No known faces to delete")
            return
        
        delete_window = tk.Toplevel(self.root)
        delete_window.title("Delete Face")
        delete_window.geometry("300x400")
        
        ttkb.Label(delete_window, text="Select face to delete:").pack(pady=10)
        
        listbox = tk.Listbox(delete_window)
        listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        for name in self.known_face_names:
            listbox.insert(tk.END, name)
        
        def delete_selected():
            selection = listbox.curselection()
            if selection:
                index = selection[0]
                name = self.known_face_names[index]
                if messagebox.askyesno("Confirm", f"Delete face for {name}?"):
                    self.known_face_names.pop(index)
                    self.known_face_encodings.pop(index)
                    self.save_known_faces()
                    self.update_status(f"Deleted face: {name}", SUCCESS)
                    delete_window.destroy()
            else:
                messagebox.showwarning("Warning", "Please select a face to delete")
        
        ttkb.Button(delete_window, text="Delete Selected", bootstyle=PRIMARY,
                   command=delete_selected).pack(pady=5)
        ttkb.Button(delete_window, text="Cancel", bootstyle=SECONDARY,
                   command=delete_window.destroy).pack(pady=5)
    
    def view_known_faces(self):
        """Show list of known faces"""
        if not self.known_face_names:
            messagebox.showinfo("Info", "No known faces registered")
            return
        
        faces_window = tk.Toplevel(self.root)
        faces_window.title("Known Faces")
        faces_window.geometry("300x400")
        
        ttkb.Label(faces_window, text=f"Total faces: {len(self.known_face_names)}",
                  font=("Arial", 12, "bold"), bootstyle=INFO).pack(pady=10)
        
        listbox = tk.Listbox(faces_window)
        listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        for i, name in enumerate(self.known_face_names, 1):
            listbox.insert(tk.END, f"{i}. {name}")
    
    def start_camera(self):
        """Start camera feed"""
        try:
            self.video_capture = cv2.VideoCapture(0)
            if self.video_capture.isOpened():
                self.camera_active = True
                self.update_camera_feed()
                self.update_status("Camera started", SUCCESS)
            else:
                self.update_status("Failed to start camera", DANGER)
                logging.error("Failed to open camera")
        except Exception as e:
            self.update_status(f"Camera error: {str(e)}", DANGER)
            logging.error(f"Camera error: {str(e)}")
    
    def stop_camera(self):
        """Stop camera feed"""
        self.camera_active = False
        self.recognition_active = False
        if self.video_capture:
            self.video_capture.release()
        self.video_label.configure(image="", text="Camera stopped")
        self.update_status("Camera stopped", INFO)
    
    def start_recognition(self):
        """Start face recognition process"""
        if not self.camera_active:
            messagebox.showwarning("Warning", "Please start the camera first")
            return
        
        if not self.known_face_encodings:
            messagebox.showwarning("Warning", "No known faces registered")
            return
        
        self.recognition_active = True
        recognition_thread = threading.Thread(target=self.recognition_loop)
        recognition_thread.daemon = True
        recognition_thread.start()
        self.update_status("Face recognition started", SUCCESS)
    
    def stop_recognition(self):
        """Stop face recognition"""
        self.recognition_active = False
        self.update_status("Face recognition stopped", INFO)
    
    def update_camera_feed(self):
        """Update camera feed in GUI with face detection boxes"""
        if self.camera_active and self.video_capture and self.video_capture.isOpened():
            ret, frame = self.video_capture.read()
            if ret:
                display_frame = frame.copy()
                
                if self.recognition_active:
                    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                    small_frame = cv2.resize(rgb_frame, (0, 0), fx=0.25, fy=0.25)
                    
                    face_locations = face_recognition.face_locations(small_frame)
                    face_encodings = face_recognition.face_encodings(small_frame, face_locations)
                    
                    for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
                        top *= 4
                        right *= 4
                        bottom *= 4
                        left *= 4
                        
                        matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
                        name = "Unknown"
                        color = (0, 0, 255)
                        
                        if True in matches:
                            face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
                            best_match_index = np.argmin(face_distances)
                            if matches[best_match_index] and face_distances[best_match_index] < 0.6:
                                name = self.known_face_names[best_match_index]
                                color = (0, 255, 0)
                        
                        cv2.rectangle(display_frame, (left, top), (right, bottom), color, 2)
                        cv2.rectangle(display_frame, (left, bottom - 35), (right, bottom), color, cv2.FILLED)
                        font = cv2.FONT_HERSHEY_DUPLEX
                        cv2.putText(display_frame, name, (left + 6, bottom - 6), font, 0.6, (255, 255, 255), 1)
                
                rgb_frame = cv2.cvtColor(display_frame, cv2.COLOR_BGR2RGB)
                img = Image.fromarray(rgb_frame)
                img = img.resize((720, 540))
                photo = ImageTk.PhotoImage(img)
                
                self.video_label.configure(image=photo, text="")
                self.video_label.image = photo
            
            self.root.after(30, self.update_camera_feed)
    
    def recognition_loop(self):
        """Main face recognition loop"""
        while self.recognition_active and self.camera_active and self.video_capture and self.video_capture.isOpened():
            ret, frame = self.video_capture.read()
            if not ret:
                continue
            
            small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
            rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
            
            face_locations = face_recognition.face_locations(rgb_small_frame)
            face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
            
            for face_encoding in face_encodings:
                matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
                name = "Unknown"
                
                if True in matches:
                    face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
                    best_match_index = np.argmin(face_distances)
                    
                    if matches[best_match_index] and face_distances[best_match_index] < 0.6:
                        name = self.known_face_names[best_match_index]
                        self.root.after(0, lambda n=name: self.update_status(f"Face recognized: {n}", SUCCESS))
                        self.root.after(0, lambda n=name: self.unlock_door_with_autolock(n))
                        time.sleep(2)
            
            time.sleep(0.1)
    
    def unlock_door_with_autolock(self, recognized_name):
        """Unlock door and start auto-lock timer"""
        if self.door_unlocked:
            self.update_status("Door is already unlocked", WARNING)
            return
        
        if self.unlock_door():
            self.door_unlocked = True
            self.update_status(f"Door unlocked for {recognized_name}", SUCCESS)
            
            if self.autolock_enabled.get():
                self.start_autolock_timer()
    
    def start_autolock_timer(self):
        """Start the auto-lock countdown timer"""
        if self.lock_timer:
            self.lock_timer.cancel()
        
        try:
            delay_seconds = int(self.autolock_var.get())
        except ValueError:
            delay_seconds = 10
            self.update_status("Invalid auto-lock time, using 10 seconds", WARNING)
            logging.warning("Invalid auto-lock time entered")
        
        self.lock_timer = threading.Timer(delay_seconds, self.auto_lock_door)
        self.lock_timer.start()
        
        self.countdown_timer(delay_seconds)
    
    def countdown_timer(self, remaining_seconds):
        """Display countdown timer"""
        if remaining_seconds > 0 and self.door_unlocked:
            self.timer_label.configure(text=f"Auto-lock in {remaining_seconds} seconds")
            self.root.after(1000, lambda: self.countdown_timer(remaining_seconds - 1))
        else:
            self.timer_label.configure(text="")
    
    def auto_lock_door(self):
        """Automatically lock the door"""
        if self.door_unlocked:
            self.lock_door()
            self.door_unlocked = False
            self.update_status("Door auto-locked", INFO)
            self.timer_label.configure(text="")
    
    def cancel_autolock(self):
        """Cancel the auto-lock timer"""
        if self.lock_timer:
            self.lock_timer.cancel()
            self.lock_timer = None
            self.timer_label.configure(text="Auto-lock cancelled")
            self.update_status("Auto-lock cancelled", WARNING)
    
    def check_connection(self):
        """Check if connection to Node.js server is active"""
        self.nodejs_server_ip = self.ip_entry.get().strip()
        if not self._is_valid_ip(self.nodejs_server_ip):
            self.update_status("Invalid IP address format", DANGER)
            return False
        
        try:
            url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/cat/corridor/status"
            response = requests.post(url, timeout=5)
            if response.status_code == 200:
                return True
            else:
                self.update_status("Error Connection", DANGER)
                return False
        except requests.exceptions.RequestException as e:
            self.update_status("Error Connection", DANGER)
            logging.error(f"Connection error: {str(e)}")
            return False

    def _is_valid_ip(self, ip):
        """Basic IP address validation"""
        pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
        if not re.match(pattern, ip):
            return False
        octets = ip.split('.')
        return all(0 <= int(o) <= 255 for o in octets)

    def test_server_connection(self):
        """Test connection to Node.js server with enhanced retry logic and feedback"""
        self.nodejs_server_ip = self.ip_entry.get().strip()
        if not self._is_valid_ip(self.nodejs_server_ip):
            self.update_status("Invalid IP address format", DANGER)
            messagebox.showerror("Error", "Please enter a valid IP address (e.g., 192.168.1.2)")
            return
        
        max_retries = 5
        retry_delay = 3
        
        for attempt in range(max_retries):
            try:
                url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/cat/corridor/status"
                response = requests.post(url, timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    lock_status = "locked" if data.get("lock") else "unlocked"
                    messagebox.showinfo("Success", f"Connected! Door status: {lock_status}")
                    self.update_status(f"Node.js server connected - Door: {lock_status}", SUCCESS)
                    return
                else:
                    self.update_status("Error Connection", DANGER)
                    messagebox.showerror("Error", f"Failed to connect to Node.js server (HTTP {response.status_code})")
                    return
            except requests.exceptions.ConnectionError as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Connection error: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    messagebox.showerror("Error", f"Connection failed after {max_retries} attempts. Check if Node.js server is running.")
            except requests.exceptions.Timeout as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Timeout error: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    messagebox.showerror("Error", f"Timeout after {max_retries} attempts. Verify Node.js server connection.")
            except requests.exceptions.RequestException as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Request error: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    messagebox.showerror("Error", f"Request failed after {max_retries} attempts. Check Node.js server configuration.")

    def unlock_door(self):
        """Send unlock command to Express.js server"""
        if not self.check_connection():
            self.update_status("Error Connection", DANGER)
            return False
        
        url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/cat/corridor/elock"
        payload = {"lock": False}
        
        max_retries = 5
        retry_delay = 3
        
        for attempt in range(max_retries):
            try:
                response = requests.post(url, json=payload, timeout=10)
                if response.status_code == 200 and response.json().get("success"):
                    self.update_status("Door unlocked!", SUCCESS)
                    return True
                else:
                    self.update_status(f"Failed to unlock door: {response.json().get('message', 'Unknown error')}", DANGER)
                    return False
            except requests.exceptions.ConnectionError as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Connection error during unlock: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    return False
            except requests.exceptions.Timeout as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Timeout error during unlock: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    return False
            except requests.exceptions.RequestException as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Request error during unlock: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    return False

    def lock_door(self):
        """Send lock command to Express.js server"""
        if not self.check_connection():
            self.update_status("Error Connection", DANGER)
            return False
        
        url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/cat/corridor/elock"
        payload = {"lock": True}
        
        max_retries = 5
        retry_delay = 3
        
        for attempt in range(max_retries):
            try:
                response = requests.post(url, json=payload, timeout=10)
                if response.status_code == 200 and response.json().get("success"):
                    self.update_status("Door locked!", SUCCESS)
                    self.door_unlocked = False
                    if self.lock_timer:
                        self.lock_timer.cancel()
                        self.timer_label.configure(text="")
                    return True
                else:
                    self.update_status(f"Failed to lock door: {response.json().get('message', 'Unknown error')}", DANGER)
                    return False
            except requests.exceptions.ConnectionError as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Connection error during lock: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    return False
            except requests.exceptions.Timeout as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Timeout error during lock: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    return False
            except requests.exceptions.RequestException as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Request error during lock: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    return False

    def check_door_status(self):
        """Check door status from Express.js server"""
        if not self.check_connection():
            self.update_status("Error Connection", DANGER)
            return
        
        url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/cat/corridor/status"
        
        max_retries = 5
        retry_delay = 3
        
        for attempt in range(max_retries):
            try:
                response = requests.post(url, timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    lock_status = "locked" if data.get("lock") else "unlocked"
                    self.update_status(f"Door status: {lock_status}", INFO)
                    messagebox.showinfo("Status", f"Door is {lock_status}")
                    return
                else:
                    self.update_status("Error Connection", DANGER)
                    return
            except requests.exceptions.ConnectionError as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Connection error checking status: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    messagebox.showerror("Error", f"Connection failed after {max_retries} attempts.")
            except requests.exceptions.Timeout as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Timeout error checking status: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    messagebox.showerror("Error", f"Timeout after {max_retries} attempts.")
            except requests.exceptions.RequestException as e:
                self.update_status("Error Connection", DANGER)
                logging.error(f"Request error checking status: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    messagebox.showerror("Error", f"Request failed after {max_retries} attempts.")
    
    def update_status(self, message, style=INFO):
        """Update status label with color-coded style"""
        try:
            self.status_label.configure(text=message, bootstyle=style)
        except Exception as e:
            logging.error(f"Error updating status label: {str(e)}")
        print(f"Status: {message}")
    
    def run(self):
        """Start the application"""
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.root.mainloop()
    
    def on_closing(self):
        """Handle application closing"""
        self.recognition_active = False
        self.stop_camera()
        self.stop_server()
        if self.lock_timer:
            self.lock_timer.cancel()
        self.root.destroy()

if __name__ == "__main__":
    try:
        import face_recognition
        import cv2
        import PIL
        import requests
        import ttkbootstrap
        import flask
    except ImportError as e:
        print("Missing required packages. Please install:")
        print("pip install face-recognition opencv-python pillow requests ttkbootstrap flask")
        exit(1)
    
    app = FaceRecognitionSystem()
    app.run()