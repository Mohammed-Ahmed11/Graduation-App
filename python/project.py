# import cv2
# import face_recognition
# import numpy as np
# import tkinter as tk
# from tkinter import ttk, filedialog, messagebox, simpledialog
# import os
# import pickle
# import requests
# import threading
# from PIL import Image, ImageTk
# import json
# import time

# class FaceRecognitionSystem:
#     def __init__(self):
#         self.root = tk.Tk()
#         self.root.title("Face Recognition Door Lock System")
#         self.root.geometry("800x600")
        
#         # ESP32 settings
#         self.esp32_ip = "192.168.1.8"  # Replace with your ESP32 IP
        
#         # Face recognition variables
#         self.known_face_encodings = []
#         self.known_face_names = []
#         self.face_locations = []
#         self.face_encodings = []
        
#         # Camera
#         self.video_capture = None
#         self.camera_active = False
#         self.recognition_active = False
        
#         # Door lock timer
#         self.lock_timer = None
#         self.door_unlocked = False
        
#         # GUI variables
#         self.video_label = None
#         self.status_label = None
        
#         self.setup_gui()
#         self.load_known_faces()
        
#     def setup_gui(self):
#         # Main frame
#         main_frame = ttk.Frame(self.root, padding="10")
#         main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
#         # Title
#         title_label = ttk.Label(main_frame, text="Face Recognition Door Lock", 
#                                font=("Arial", 16, "bold"))
#         title_label.grid(row=0, column=0, columnspan=3, pady=10)
        
#         # ESP32 IP configuration
#         ip_frame = ttk.LabelFrame(main_frame, text="ESP32 Configuration", padding="5")
#         ip_frame.grid(row=1, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
#         ttk.Label(ip_frame, text="ESP32 IP:").grid(row=0, column=0, padx=5)
#         self.ip_entry = ttk.Entry(ip_frame, width=20)
#         self.ip_entry.insert(0, self.esp32_ip)
#         self.ip_entry.grid(row=0, column=1, padx=5)
        
#         ttk.Button(ip_frame, text="Test Connection", 
#                   command=self.test_esp32_connection).grid(row=0, column=2, padx=5)
        
#         # Auto-lock settings
#         autolock_frame = ttk.LabelFrame(main_frame, text="Auto-Lock Settings", padding="5")
#         autolock_frame.grid(row=2, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
#         ttk.Label(autolock_frame, text="Auto-lock after (seconds):").grid(row=0, column=0, padx=5)
#         self.autolock_var = tk.StringVar(value="10")
#         autolock_spinbox = ttk.Spinbox(autolock_frame, from_=5, to=60, width=10, 
#                                       textvariable=self.autolock_var)
#         autolock_spinbox.grid(row=0, column=1, padx=5)
        
#         self.autolock_enabled = tk.BooleanVar(value=True)
#         ttk.Checkbutton(autolock_frame, text="Enable Auto-lock", 
#                        variable=self.autolock_enabled).grid(row=0, column=2, padx=5)
        
#         # Face management frame
#         face_frame = ttk.LabelFrame(main_frame, text="Face Management", padding="5")
#         face_frame.grid(row=3, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
#         ttk.Button(face_frame, text="Add Faces from Folder", 
#                   command=self.add_faces_from_folder).grid(row=0, column=0, padx=5)
#         ttk.Button(face_frame, text="Add Face from Camera", 
#                   command=self.add_face_from_camera).grid(row=0, column=1, padx=5)
#         ttk.Button(face_frame, text="View Known Faces", 
#                   command=self.view_known_faces).grid(row=0, column=2, padx=5)
#         ttk.Button(face_frame, text="Delete Face", 
#                   command=self.delete_face).grid(row=0, column=3, padx=5)
        
#         # Camera frame
#         camera_frame = ttk.LabelFrame(main_frame, text="Camera", padding="5")
#         camera_frame.grid(row=4, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
#         self.video_label = ttk.Label(camera_frame, text="Camera feed will appear here")
#         self.video_label.grid(row=0, column=0, columnspan=4, pady=10)
        
#         ttk.Button(camera_frame, text="Start Camera", 
#                   command=self.start_camera).grid(row=1, column=0, padx=5)
#         ttk.Button(camera_frame, text="Stop Camera", 
#                   command=self.stop_camera).grid(row=1, column=1, padx=5)
#         ttk.Button(camera_frame, text="Start Recognition", 
#                   command=self.start_recognition).grid(row=1, column=2, padx=5)
#         ttk.Button(camera_frame, text="Stop Recognition", 
#                   command=self.stop_recognition).grid(row=1, column=3, padx=5)
        
#         # Door control frame
#         door_frame = ttk.LabelFrame(main_frame, text="Door Control", padding="5")
#         door_frame.grid(row=5, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
#         ttk.Button(door_frame, text="Unlock Door", 
#                   command=self.unlock_door).grid(row=0, column=0, padx=5)
#         ttk.Button(door_frame, text="Lock Door", 
#                   command=self.lock_door).grid(row=0, column=1, padx=5)
#         ttk.Button(door_frame, text="Check Status", 
#                   command=self.check_door_status).grid(row=0, column=2, padx=5)
#         ttk.Button(door_frame, text="Cancel Auto-lock", 
#                   command=self.cancel_autolock).grid(row=0, column=3, padx=5)
        
#         # Status frame
#         status_frame = ttk.LabelFrame(main_frame, text="Status", padding="5")
#         status_frame.grid(row=6, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
#         self.status_label = ttk.Label(status_frame, text="Ready", 
#                                      font=("Arial", 12))
#         self.status_label.grid(row=0, column=0, pady=5)
        
#         # Timer display
#         self.timer_label = ttk.Label(status_frame, text="", 
#                                     font=("Arial", 10), foreground="red")
#         self.timer_label.grid(row=1, column=0, pady=2)
        
#     def load_known_faces(self):
#         """Load known faces from pickle file"""
#         try:
#             if os.path.exists("known_faces.pkl"):
#                 with open("known_faces.pkl", "rb") as f:
#                     data = pickle.load(f)
#                     self.known_face_encodings = data["encodings"]
#                     self.known_face_names = data["names"]
#                 self.update_status(f"Loaded {len(self.known_face_names)} known faces")
#             else:
#                 self.update_status("No known faces file found")
#         except Exception as e:
#             self.update_status(f"Error loading faces: {str(e)}")
    
#     def save_known_faces(self):
#         """Save known faces to pickle file"""
#         try:
#             data = {
#                 "encodings": self.known_face_encodings,
#                 "names": self.known_face_names
#             }
#             with open("known_faces.pkl", "wb") as f:
#                 pickle.dump(data, f)
#             self.update_status("Faces saved successfully")
#         except Exception as e:
#             self.update_status(f"Error saving faces: {str(e)}")
    
#     def add_faces_from_folder(self):
#         """Add faces from a selected folder - supports PNG, JPG, JPEG"""
#         folder_path = filedialog.askdirectory(title="Select folder containing face images")
#         if not folder_path:
#             return
        
#         added_count = 0
#         supported_formats = ('.png', '.jpg', '.jpeg', '.bmp', '.tiff')
        
#         for filename in os.listdir(folder_path):
#             if filename.lower().endswith(supported_formats):
#                 image_path = os.path.join(folder_path, filename)
#                 name = os.path.splitext(filename)[0]
                
#                 try:
#                     # Load image
#                     image = face_recognition.load_image_file(image_path)
#                     face_encodings = face_recognition.face_encodings(image)
                    
#                     if face_encodings:
#                         # Check if this person already exists
#                         if name not in self.known_face_names:
#                             self.known_face_encodings.append(face_encodings[0])
#                             self.known_face_names.append(name)
#                             added_count += 1
#                             self.update_status(f"Added face: {name}")
#                         else:
#                             self.update_status(f"Face {name} already exists, skipping")
#                     else:
#                         self.update_status(f"No face found in {filename}")
#                 except Exception as e:
#                     self.update_status(f"Error processing {filename}: {str(e)}")
        
#         if added_count > 0:
#             self.save_known_faces()
#             messagebox.showinfo("Success", f"Added {added_count} new faces successfully!")
#         else:
#             messagebox.showinfo("Info", "No new faces were added")
    
#     def add_face_from_camera(self):
#         """Add a face from camera capture"""
#         if not self.camera_active:
#             messagebox.showwarning("Warning", "Please start the camera first")
#             return
        
#         name = simpledialog.askstring("Input", "Enter name for this face:")
#         if not name:
#             return
        
#         if name in self.known_face_names:
#             if not messagebox.askyesno("Confirm", f"Face for {name} already exists. Replace it?"):
#                 return
#             # Remove existing face
#             index = self.known_face_names.index(name)
#             self.known_face_names.pop(index)
#             self.known_face_encodings.pop(index)
        
#         if self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if ret:
#                 rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
#                 face_encodings = face_recognition.face_encodings(rgb_frame)
                
#                 if face_encodings:
#                     self.known_face_encodings.append(face_encodings[0])
#                     self.known_face_names.append(name)
#                     self.save_known_faces()
#                     messagebox.showinfo("Success", f"Face added for {name}")
#                     self.update_status(f"Added face for {name}")
#                 else:
#                     messagebox.showwarning("Warning", "No face detected in current frame")
    
#     def delete_face(self):
#         """Delete a known face"""
#         if not self.known_face_names:
#             messagebox.showinfo("Info", "No known faces to delete")
#             return
        
#         # Create selection window
#         delete_window = tk.Toplevel(self.root)
#         delete_window.title("Delete Face")
#         delete_window.geometry("300x400")
        
#         ttk.Label(delete_window, text="Select face to delete:").pack(pady=10)
        
#         listbox = tk.Listbox(delete_window)
#         listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         for name in self.known_face_names:
#             listbox.insert(tk.END, name)
        
#         def delete_selected():
#             selection = listbox.curselection()
#             if selection:
#                 index = selection[0]
#                 name = self.known_face_names[index]
#                 if messagebox.askyesno("Confirm", f"Delete face for {name}?"):
#                     self.known_face_names.pop(index)
#                     self.known_face_encodings.pop(index)
#                     self.save_known_faces()
#                     self.update_status(f"Deleted face: {name}")
#                     delete_window.destroy()
#             else:
#                 messagebox.showwarning("Warning", "Please select a face to delete")
        
#         ttk.Button(delete_window, text="Delete Selected", command=delete_selected).pack(pady=5)
#         ttk.Button(delete_window, text="Cancel", command=delete_window.destroy).pack(pady=5)
    
#     def view_known_faces(self):
#         """Show list of known faces"""
#         if not self.known_face_names:
#             messagebox.showinfo("Info", "No known faces registered")
#             return
        
#         faces_window = tk.Toplevel(self.root)
#         faces_window.title("Known Faces")
#         faces_window.geometry("300x400")
        
#         ttk.Label(faces_window, text=f"Total faces: {len(self.known_face_names)}", 
#                  font=("Arial", 12, "bold")).pack(pady=10)
        
#         listbox = tk.Listbox(faces_window)
#         listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         for i, name in enumerate(self.known_face_names, 1):
#             listbox.insert(tk.END, f"{i}. {name}")
    
#     def start_camera(self):
#         """Start camera feed"""
#         try:
#             self.video_capture = cv2.VideoCapture(0)
#             if self.video_capture.isOpened():
#                 self.camera_active = True
#                 self.update_camera_feed()
#                 self.update_status("Camera started")
#             else:
#                 self.update_status("Failed to start camera")
#         except Exception as e:
#             self.update_status(f"Camera error: {str(e)}")
    
#     def stop_camera(self):
#         """Stop camera feed"""
#         self.camera_active = False
#         self.recognition_active = False
#         if self.video_capture:
#             self.video_capture.release()
#         self.video_label.configure(image="", text="Camera stopped")
#         self.update_status("Camera stopped")
    
#     def start_recognition(self):
#         """Start face recognition process"""
#         if not self.camera_active:
#             messagebox.showwarning("Warning", "Please start the camera first")
#             return
        
#         if not self.known_face_encodings:
#             messagebox.showwarning("Warning", "No known faces registered")
#             return
        
#         self.recognition_active = True
#         # Start recognition in separate thread
#         recognition_thread = threading.Thread(target=self.recognition_loop)
#         recognition_thread.daemon = True
#         recognition_thread.start()
#         self.update_status("Face recognition started")
    
#     def stop_recognition(self):
#         """Stop face recognition"""
#         self.recognition_active = False
#         self.update_status("Face recognition stopped")
    
#     def update_camera_feed(self):
#         """Update camera feed in GUI with face detection boxes"""
#         if self.camera_active and self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if ret:
#                 display_frame = frame.copy()
                
#                 # If recognition is active, draw face boxes
#                 if self.recognition_active:
#                     rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
#                     small_frame = cv2.resize(rgb_frame, (0, 0), fx=0.25, fy=0.25)
                    
#                     face_locations = face_recognition.face_locations(small_frame)
#                     face_encodings = face_recognition.face_encodings(small_frame, face_locations)
                    
#                     for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
#                         # Scale back up face locations
#                         top *= 4
#                         right *= 4
#                         bottom *= 4
#                         left *= 4
                        
#                         # Check if face matches known faces
#                         matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
#                         name = "Unknown"
#                         color = (0, 0, 255)  # Red for unknown
                        
#                         if True in matches:
#                             face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
#                             best_match_index = np.argmin(face_distances)
#                             if matches[best_match_index] and face_distances[best_match_index] < 0.6:
#                                 name = self.known_face_names[best_match_index]
#                                 color = (0, 255, 0)  # Green for known
                        
#                         # Draw rectangle and name
#                         cv2.rectangle(display_frame, (left, top), (right, bottom), color, 2)
#                         cv2.rectangle(display_frame, (left, bottom - 35), (right, bottom), color, cv2.FILLED)
#                         font = cv2.FONT_HERSHEY_DUPLEX
#                         cv2.putText(display_frame, name, (left + 6, bottom - 6), font, 0.6, (255, 255, 255), 1)
                
#                 # Convert frame for tkinter
#                 rgb_frame = cv2.cvtColor(display_frame, cv2.COLOR_BGR2RGB)
#                 img = Image.fromarray(rgb_frame)
#                 img = img.resize((640, 480))
#                 photo = ImageTk.PhotoImage(img)
                
#                 self.video_label.configure(image=photo, text="")
#                 self.video_label.image = photo
            
#             # Schedule next update
#             self.root.after(30, self.update_camera_feed)
    
#     def recognition_loop(self):
#         """Main face recognition loop"""
#         while self.recognition_active and self.camera_active and self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if not ret:
#                 continue
            
#             # Resize frame for faster processing
#             small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
#             rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
            
#             # Find faces in current frame
#             face_locations = face_recognition.face_locations(rgb_small_frame)
#             face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
            
#             for face_encoding in face_encodings:
#                 # Compare with known faces
#                 matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
#                 name = "Unknown"
                
#                 # Use the known face with the smallest distance
#                 if True in matches:
#                     face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
#                     best_match_index = np.argmin(face_distances)
                    
#                     if matches[best_match_index] and face_distances[best_match_index] < 0.6:
#                         name = self.known_face_names[best_match_index]
#                         # Recognized face - unlock door
#                         self.root.after(0, lambda n=name: self.update_status(f"Face recognized: {n}"))
#                         self.root.after(0, lambda n=name: self.unlock_door_with_autolock(n))
#                         # Wait a bit before checking again to avoid multiple triggers
#                         time.sleep(2)
            
#             # Small delay to prevent excessive CPU usage
#             time.sleep(0.1)
    
#     def unlock_door_with_autolock(self, recognized_name):
#         """Unlock door and start auto-lock timer"""
#         if self.unlock_door():
#             self.door_unlocked = True
#             self.update_status(f"Door unlocked for {recognized_name}")
            
#             if self.autolock_enabled.get():
#                 self.start_autolock_timer()
    
#     def start_autolock_timer(self):
#         """Start the auto-lock countdown timer"""
#         if self.lock_timer:
#             self.lock_timer.cancel()
        
#         delay_seconds = int(self.autolock_var.get())
#         self.lock_timer = threading.Timer(delay_seconds, self.auto_lock_door)
#         self.lock_timer.start()
        
#         # Start countdown display
#         self.countdown_timer(delay_seconds)
    
#     def countdown_timer(self, remaining_seconds):
#         """Display countdown timer"""
#         if remaining_seconds > 0 and self.door_unlocked:
#             self.timer_label.configure(text=f"Auto-lock in {remaining_seconds} seconds")
#             self.root.after(1000, lambda: self.countdown_timer(remaining_seconds - 1))
#         else:
#             self.timer_label.configure(text="")
    
#     def auto_lock_door(self):
#         """Automatically lock the door"""
#         if self.door_unlocked:
#             self.lock_door()
#             self.door_unlocked = False
#             self.update_status("Door auto-locked")
#             self.timer_label.configure(text="")
    
#     def cancel_autolock(self):
#         """Cancel the auto-lock timer"""
#         if self.lock_timer:
#             self.lock_timer.cancel()
#             self.lock_timer = None
#             self.timer_label.configure(text="Auto-lock cancelled")
#             self.update_status("Auto-lock cancelled")
    
#     def test_esp32_connection(self):
#         """Test connection to ESP32"""
#         self.esp32_ip = self.ip_entry.get()
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/status", timeout=5)
#             if response.status_code == 200:
#                 data = response.json()
#                 messagebox.showinfo("Success", f"Connected! Door status: {data['status']}")
#                 self.update_status(f"ESP32 connected - Door: {data['status']}")
#             else:
#                 messagebox.showerror("Error", "Failed to connect to ESP32")
#         except Exception as e:
#             messagebox.showerror("Error", f"Connection failed: {str(e)}")
#             self.update_status(f"ESP32 connection failed: {str(e)}")
    
#     def unlock_door(self):
#         """Send unlock command to ESP32"""
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/unlock", timeout=5)
#             if response.status_code == 200:
#                 self.update_status("Door unlocked!")
#                 return True
#             else:
#                 self.update_status("Failed to unlock door")
#                 return False
#         except Exception as e:
#             self.update_status(f"Unlock error: {str(e)}")
#             return False
    
#     def lock_door(self):
#         """Send lock command to ESP32"""
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/lock", timeout=5)
#             if response.status_code == 200:
#                 self.update_status("Door locked!")
#                 self.door_unlocked = False
#                 if self.lock_timer:
#                     self.lock_timer.cancel()
#                     self.timer_label.configure(text="")
#                 return True
#             else:
#                 self.update_status("Failed to lock door")
#                 return False
#         except Exception as e:
#             self.update_status(f"Lock error: {str(e)}")
#             return False
    
#     def check_door_status(self):
#         """Check door status from ESP32"""
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/status", timeout=5)
#             if response.status_code == 200:
#                 data = response.json()
#                 status = data['status']
#                 self.update_status(f"Door status: {status}")
#                 messagebox.showinfo("Status", f"Door is {status}")
#             else:
#                 self.update_status("Failed to get door status")
#         except Exception as e:
#             self.update_status(f"Status check error: {str(e)}")
    
#     def update_status(self, message):
#         """Update status label"""
#         self.status_label.configure(text=message)
#         print(f"Status: {message}")
    
#     def run(self):
#         """Start the application"""
#         self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
#         self.root.mainloop()
    
#     def on_closing(self):
#         """Handle application closing"""
#         self.recognition_active = False
#         self.stop_camera()
#         if self.lock_timer:
#             self.lock_timer.cancel()
#         self.root.destroy()

# if __name__ == "__main__":
#     # Install required packages if not installed
#     try:
#         import face_recognition
#         import cv2
#         import PIL
#         import requests
#     except ImportError as e:
#         print("Missing required packages. Please install:")
#         print("pip install face-recognition opencv-python pillow requests")
#         exit(1)
    
#     app = FaceRecognitionSystem()
#     app.run()

#22222222222222222222222222222222222222222222222222222222222222222222



# import cv2
# import face_recognition
# import numpy as np
# import tkinter as tk
# from tkinter import ttk, filedialog, messagebox, simpledialog
# import ttkbootstrap as ttkb
# from ttkbootstrap.constants import *
# from ttkbootstrap.tooltip import ToolTip
# import os
# import pickle
# import requests
# import threading
# from PIL import Image, ImageTk
# import json
# import time

# class FaceRecognitionSystem:
#     def __init__(self):
#         self.root = ttkb.Window(themename="litera")  # Use ttkbootstrap with 'litera' theme
#         self.root.title("Face Recognition Door Lock System")
#         self.root.geometry("1000x700")  # Slightly larger window for better layout
        
#         # ESP32 settings
#         self.esp32_ip = "192.168.1.8"  # Replace with your ESP32 IP
        
#         # Face recognition variables
#         self.known_face_encodings = []
#         self.known_face_names = []
#         self.face_locations = []
#         self.face_encodings = []
        
#         # Camera
#         self.video_capture = None
#         self.camera_active = False
#         self.recognition_active = False
        
#         # Door lock timer
#         self.lock_timer = None
#         self.door_unlocked = False
        
#         # GUI variables
#         self.video_label = None
#         self.status_label = None
#         self.icon_cache = {}  # Cache for button icons
        
#         self.setup_gui()
#         self.load_known_faces()
        
#     def load_icon(self, icon_path, size=(20, 20)):
#         """Load and resize icon for buttons"""
#         if icon_path not in self.icon_cache:
#             try:
#                 img = Image.open(icon_path).resize(size, Image.LANCZOS)
#                 self.icon_cache[icon_path] = ImageTk.PhotoImage(img)
#             except:
#                 return None
#         return self.icon_cache[icon_path]
        
#     def setup_gui(self):
#         """Set up the improved GUI layout"""
#         # Configure root grid for responsiveness
#         self.root.grid_rowconfigure(0, weight=1)
#         self.root.grid_columnconfigure(0, weight=0)  # Sidebar
#         self.root.grid_columnconfigure(1, weight=1)  # Main content
        
#         # Sidebar frame
#         sidebar = ttkb.Frame(self.root, padding=10, bootstyle=SECONDARY)
#         sidebar.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.W), padx=5, pady=5)
#         sidebar.grid_rowconfigure(10, weight=1)  # Push status to bottom
        
#         # Main content frame
#         main_frame = ttkb.Frame(self.root, padding=10)
#         main_frame.grid(row=0, column=1, sticky=(tk.N, tk.S, tk.E, tk.W), padx=5, pady=5)
#         main_frame.grid_rowconfigure(1, weight=1)
#         main_frame.grid_columnconfigure(0, weight=1)
        
#         # Title in sidebar
#         title_label = ttkb.Label(sidebar, text="Face Door Lock", 
#                                 font=("Arial", 16, "bold"), bootstyle=INFO)
#         title_label.pack(pady=10, fill=tk.X)
        
#         # ESP32 Configuration
#         ip_frame = ttkb.LabelFrame(sidebar, text="ESP32 Config", padding=5)
#         ip_frame.pack(fill=tk.X, pady=5)
        
#         ip_subframe = ttkb.Frame(ip_frame)
#         ip_subframe.pack(fill=tk.X, padx=5, pady=5)
        
#         ttkb.Label(ip_subframe, text="IP Address:").pack(side=tk.LEFT, padx=5)
#         self.ip_entry = ttkb.Entry(ip_subframe, width=15)
#         self.ip_entry.insert(0, self.esp32_ip)
#         self.ip_entry.pack(side=tk.LEFT, padx=5)
        
#         test_icon = self.load_icon("icons/test.png")  # Replace with actual icon path
#         test_btn = ttkb.Button(ip_frame, text="Test", bootstyle=INFO, 
#                               command=self.test_esp32_connection, image=test_icon, 
#                               compound=tk.LEFT)
#         test_btn.pack(fill=tk.X, padx=5, pady=5)
#         ToolTip(test_btn, text="Test connection to ESP32")
        
#         # Auto-lock Settings
#         autolock_frame = ttkb.LabelFrame(sidebar, text="Auto-Lock", padding=5)
#         autolock_frame.pack(fill=tk.X, pady=5)
        
#         autolock_subframe = ttkb.Frame(autolock_frame)
#         autolock_subframe.pack(fill=tk.X, padx=5, pady=5)
        
#         ttkb.Label(autolock_subframe, text="Seconds:").pack(side=tk.LEFT, padx=5)
#         self.autolock_var = tk.StringVar(value="10")
#         autolock_spinbox = ttkb.Spinbox(autolock_subframe, from_=5, to=60, width=5, 
#                                        textvariable=self.autolock_var)
#         autolock_spinbox.pack(side=tk.LEFT, padx=5)
        
#         self.autolock_enabled = tk.BooleanVar(value=True)
#         ttkb.Checkbutton(autolock_frame, text="Enable Auto-lock", 
#                         variable=self.autolock_enabled, bootstyle=INFO).pack(padx=5, pady=5)
        
#         # Face Management
#         face_frame = ttkb.LabelFrame(sidebar, text="Face Management", padding=5)
#         face_frame.pack(fill=tk.X, pady=5)
        
#         add_folder_icon = self.load_icon("icons/folder_add.png")
#         ttkb.Button(face_frame, text="Add from Folder", bootstyle=PRIMARY, 
#                    command=self.add_faces_from_folder, image=add_folder_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         add_camera_icon = self.load_icon("icons/camera_add.png")
#         ttkb.Button(face_frame, text="Add from Camera", bootstyle=PRIMARY, 
#                    command=self.add_face_from_camera, image=add_camera_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         view_icon = self.load_icon("icons/view.png")
#         ttkb.Button(face_frame, text="View Faces", bootstyle=PRIMARY, 
#                    command=self.view_known_faces, image=view_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         delete_icon = self.load_icon("icons/delete.png")
#         ttkb.Button(face_frame, text="Delete Face", bootstyle=PRIMARY, 
#                    command=self.delete_face, image=delete_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         # Door Control
#         door_frame = ttkb.LabelFrame(sidebar, text="Door Control", padding=5)
#         door_frame.pack(fill=tk.X, pady=5)
        
#         unlock_icon = self.load_icon("icons/unlock.png")
#         ttkb.Button(door_frame, text="Unlock", bootstyle=SUCCESS, 
#                    command=self.unlock_door, image=unlock_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         lock_icon = self.load_icon("icons/lock.png")
#         ttkb.Button(door_frame, text="Lock", bootstyle=DANGER, 
#                    command=self.lock_door, image=lock_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         status_icon = self.load_icon("icons/status.png")
#         ttkb.Button(door_frame, text="Check Status", bootstyle=INFO, 
#                    command=self.check_door_status, image=status_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         cancel_icon = self.load_icon("icons/cancel.png")
#         ttkb.Button(door_frame, text="Cancel Auto-lock", bootstyle=WARNING, 
#                    command=self.cancel_autolock, image=cancel_icon, 
#                    compound=tk.LEFT).pack(fill=tk.X, padx=5, pady=2)
        
#         # Status Frame (at bottom of sidebar)
#         status_frame = ttkb.LabelFrame(sidebar, text="Status", padding=5)
#         status_frame.pack(fill=tk.X, pady=5, side=tk.BOTTOM)
        
#         self.status_label = ttkb.Label(status_frame, text="Ready", 
#                                       font=("Arial", 12), bootstyle=INFO)
#         self.status_label.pack(pady=5)
        
#         self.timer_label = ttkb.Label(status_frame, text="", 
#                                      font=("Arial", 10), bootstyle=DANGER)
#         self.timer_label.pack(pady=2)
        
#         # Camera Frame (in main content)
#         camera_frame = ttkb.LabelFrame(main_frame, text="Camera Feed", padding=5)
#         camera_frame.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.E, tk.W), pady=5)
#         camera_frame.grid_rowconfigure(0, weight=1)
#         camera_frame.grid_columnconfigure(0, weight=1)
        
#         self.video_label = ttkb.Label(camera_frame, text="Camera feed will appear here", 
#                                      bootstyle=SECONDARY)
#         self.video_label.grid(row=0, column=0, pady=10, sticky=(tk.N, tk.S, tk.E, tk.W))
        
#         # Camera Controls
#         camera_controls = ttkb.Frame(camera_frame)
#         camera_controls.grid(row=1, column=0, pady=5, sticky=tk.E)
        
#         start_cam_icon = self.load_icon("icons/camera_start.png")
#         ttkb.Button(camera_controls, text="Start Camera", bootstyle=SUCCESS, 
#                    command=self.start_camera, image=start_cam_icon, 
#                    compound=tk.LEFT).pack(side=tk.LEFT, padx=5)
        
#         stop_cam_icon = self.load_icon("icons/camera_stop.png")
#         ttkb.Button(camera_controls, text="Stop Camera", bootstyle=DANGER, 
#                    command=self.stop_camera, image=stop_cam_icon, 
#                    compound=tk.LEFT).pack(side=tk.LEFT, padx=5)
        
#         start_rec_icon = self.load_icon("icons/recognition_start.png")
#         ttkb.Button(camera_controls, text="Start Recognition", bootstyle=PRIMARY, 
#                    command=self.start_recognition, image=start_rec_icon, 
#                    compound=tk.LEFT).pack(side=tk.LEFT, padx=5)
        
#         stop_rec_icon = self.load_icon("icons/recognition_stop.png")
#         ttkb.Button(camera_controls, text="Stop Recognition", bootstyle=WARNING, 
#                    command=self.stop_recognition, image=stop_rec_icon, 
#                    compound=tk.LEFT).pack(side=tk.LEFT, padx=5)
    
#     def load_known_faces(self):
#         """Load known faces from pickle file"""
#         try:
#             if os.path.exists("known_faces.pkl"):
#                 with open("known_faces.pkl", "rb") as f:
#                     data = pickle.load(f)
#                     self.known_face_encodings = data["encodings"]
#                     self.known_face_names = data["names"]
#                 self.update_status(f"Loaded {len(self.known_face_names)} known faces", SUCCESS)
#             else:
#                 self.update_status("No known faces file found", WARNING)
#         except Exception as e:
#             self.update_status(f"Error loading faces: {str(e)}", DANGER)
    
#     def save_known_faces(self):
#         """Save known faces to pickle file"""
#         try:
#             data = {
#                 "encodings": self.known_face_encodings,
#                 "names": self.known_face_names
#             }
#             with open("known_faces.pkl", "wb") as f:
#                 pickle.dump(data, f)
#             self.update_status("Faces saved successfully", SUCCESS)
#         except Exception as e:
#             self.update_status(f"Error saving faces: {str(e)}", DANGER)
    
#     def add_faces_from_folder(self):
#         """Add faces from a selected folder - supports PNG, JPG, JPEG"""
#         folder_path = filedialog.askdirectory(title="Select folder containing face images")
#         if not folder_path:
#             return
        
#         added_count = 0
#         supported_formats = ('.png', '.jpg', '.jpeg', '.bmp', '.tiff')
        
#         for filename in os.listdir(folder_path):
#             if filename.lower().endswith(supported_formats):
#                 image_path = os.path.join(folder_path, filename)
#                 name = os.path.splitext(filename)[0]
                
#                 try:
#                     image = face_recognition.load_image_file(image_path)
#                     face_encodings = face_recognition.face_encodings(image)
                    
#                     if face_encodings:
#                         if name not in self.known_face_names:
#                             self.known_face_encodings.append(face_encodings[0])
#                             self.known_face_names.append(name)
#                             added_count += 1
#                             self.update_status(f"Added face: {name}", SUCCESS)
#                         else:
#                             self.update_status(f"Face {name} already exists, skipping", WARNING)
#                     else:
#                         self.update_status(f"No face found in {filename}", WARNING)
#                 except Exception as e:
#                     self.update_status(f"Error processing {filename}: {str(e)}", DANGER)
        
#         if added_count > 0:
#             self.save_known_faces()
#             messagebox.showinfo("Success", f"Added {added_count} new faces successfully!")
#         else:
#             messagebox.showinfo("Info", "No new faces were added")
    
#     def add_face_from_camera(self):
#         """Add a face from camera capture"""
#         if not self.camera_active:
#             messagebox.showwarning("Warning", "Please start the camera first")
#             return
        
#         name = simpledialog.askstring("Input", "Enter name for this face:")
#         if not name:
#             return
        
#         if name in self.known_face_names:
#             if not messagebox.askyesno("Confirm", f"Face for {name} already exists. Replace it?"):
#                 return
#             index = self.known_face_names.index(name)
#             self.known_face_names.pop(index)
#             self.known_face_encodings.pop(index)
        
#         if self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if ret:
#                 rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
#                 face_encodings = face_recognition.face_encodings(rgb_frame)
                
#                 if face_encodings:
#                     self.known_face_encodings.append(face_encodings[0])
#                     self.known_face_names.append(name)
#                     self.save_known_faces()
#                     messagebox.showinfo("Success", f"Face added for {name}")
#                     self.update_status(f"Added face for {name}", SUCCESS)
#                 else:
#                     messagebox.showwarning("Warning", "No face detected in current frame")
    
#     def delete_face(self):
#         """Delete a known face"""
#         if not self.known_face_names:
#             messagebox.showinfo("Info", "No known faces to delete")
#             return
        
#         delete_window = tk.Toplevel(self.root)
#         delete_window.title("Delete Face")
#         delete_window.geometry("300x400")
        
#         ttkb.Label(delete_window, text="Select face to delete:").pack(pady=10)
        
#         listbox = tk.Listbox(delete_window)
#         listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         for name in self.known_face_names:
#             listbox.insert(tk.END, name)
        
#         def delete_selected():
#             selection = listbox.curselection()
#             if selection:
#                 index = selection[0]
#                 name = self.known_face_names[index]
#                 if messagebox.askyesno("Confirm", f"Delete face for {name}?"):
#                     self.known_face_names.pop(index)
#                     self.known_face_encodings.pop(index)
#                     self.save_known_faces()
#                     self.update_status(f"Deleted face: {name}", SUCCESS)
#                     delete_window.destroy()
#             else:
#                 messagebox.showwarning("Warning", "Please select a face to delete")
        
#         ttkb.Button(delete_window, text="Delete Selected", bootstyle=PRIMARY, 
#                    command=delete_selected).pack(pady=5)
#         ttkb.Button(delete_window, text="Cancel", bootstyle=SECONDARY, 
#                    command=delete_window.destroy).pack(pady=5)
    
#     def view_known_faces(self):
#         """Show list of known faces"""
#         if not self.known_face_names:
#             messagebox.showinfo("Info", "No known faces registered")
#             return
        
#         faces_window = tk.Toplevel(self.root)
#         faces_window.title("Known Faces")
#         faces_window.geometry("300x400")
        
#         ttkb.Label(faces_window, text=f"Total faces: {len(self.known_face_names)}", 
#                   font=("Arial", 12, "bold"), bootstyle=INFO).pack(pady=10)
        
#         listbox = tk.Listbox(faces_window)
#         listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         for i, name in enumerate(self.known_face_names, 1):
#             listbox.insert(tk.END, f"{i}. {name}")
    
#     def start_camera(self):
#         """Start camera feed"""
#         try:
#             self.video_capture = cv2.VideoCapture(0)
#             if self.video_capture.isOpened():
#                 self.camera_active = True
#                 self.update_camera_feed()
#                 self.update_status("Camera started", SUCCESS)
#             else:
#                 self.update_status("Failed to start camera", DANGER)
#         except Exception as e:
#             self.update_status(f"Camera error: {str(e)}", DANGER)
    
#     def stop_camera(self):
#         """Stop camera feed"""
#         self.camera_active = False
#         self.recognition_active = False
#         if self.video_capture:
#             self.video_capture.release()
#         self.video_label.configure(image="", text="Camera stopped")
#         self.update_status("Camera stopped", INFO)
    
#     def start_recognition(self):
#         """Start face recognition process"""
#         if not self.camera_active:
#             messagebox.showwarning("Warning", "Please start the camera first")
#             return
        
#         if not self.known_face_encodings:
#             messagebox.showwarning("Warning", "No known faces registered")
#             return
        
#         self.recognition_active = True
#         recognition_thread = threading.Thread(target=self.recognition_loop)
#         recognition_thread.daemon = True
#         recognition_thread.start()
#         self.update_status("Face recognition started", SUCCESS)
    
#     def stop_recognition(self):
#         """Stop face recognition"""
#         self.recognition_active = False
#         self.update_status("Face recognition stopped", INFO)
    
#     def update_camera_feed(self):
#         """Update camera feed in GUI with face detection boxes"""
#         if self.camera_active and self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if ret:
#                 display_frame = frame.copy()
                
#                 if self.recognition_active:
#                     rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
#                     small_frame = cv2.resize(rgb_frame, (0, 0), fx=0.25, fy=0.25)
                    
#                     face_locations = face_recognition.face_locations(small_frame)
#                     face_encodings = face_recognition.face_encodings(small_frame, face_locations)
                    
#                     for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
#                         top *= 4
#                         right *= 4
#                         bottom *= 4
#                         left *= 4
                        
#                         matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
#                         name = "Unknown"
#                         color = (0, 0, 255)  # Red for unknown
                        
#                         if True in matches:
#                             face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
#                             best_match_index = np.argmin(face_distances)
#                             if matches[best_match_index] and face_distances[best_match_index] < 0.6:
#                                 name = self.known_face_names[best_match_index]
#                                 color = (0, 255, 0)  # Green for known
                        
#                         cv2.rectangle(display_frame, (left, top), (right, bottom), color, 2)
#                         cv2.rectangle(display_frame, (left, bottom - 35), (right, bottom), color, cv2.FILLED)
#                         font = cv2.FONT_HERSHEY_DUPLEX
#                         cv2.putText(display_frame, name, (left + 6, bottom - 6), font, 0.6, (255, 255, 255), 1)
                
#                 rgb_frame = cv2.cvtColor(display_frame, cv2.COLOR_BGR2RGB)
#                 img = Image.fromarray(rgb_frame)
#                 img = img.resize((720, 540))  # Adjusted for larger window
#                 photo = ImageTk.PhotoImage(img)
                
#                 self.video_label.configure(image=photo, text="")
#                 self.video_label.image = photo
            
#             self.root.after(30, self.update_camera_feed)
    
#     def recognition_loop(self):
#         """Main face recognition loop"""
#         while self.recognition_active and self.camera_active and self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if not ret:
#                 continue
            
#             small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
#             rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
            
#             face_locations = face_recognition.face_locations(rgb_small_frame)
#             face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
            
#             for face_encoding in face_encodings:
#                 matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
#                 name = "Unknown"
                
#                 if True in matches:
#                     face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
#                     best_match_index = np.argmin(face_distances)
                    
#                     if matches[best_match_index] and face_distances[best_match_index] < 0.6:
#                         name = self.known_face_names[best_match_index]
#                         self.root.after(0, lambda n=name: self.update_status(f"Face recognized: {n}", SUCCESS))
#                         self.root.after(0, lambda n=name: self.unlock_door_with_autolock(n))
#                         time.sleep(2)
            
#             time.sleep(0.1)
    
#     def unlock_door_with_autolock(self, recognized_name):
#         """Unlock door and start auto-lock timer"""
#         if self.unlock_door():
#             self.door_unlocked = True
#             self.update_status(f"Door unlocked for {recognized_name}", SUCCESS)
            
#             if self.autolock_enabled.get():
#                 self.start_autolock_timer()
    
#     def start_autolock_timer(self):
#         """Start the auto-lock countdown timer"""
#         if self.lock_timer:
#             self.lock_timer.cancel()
        
#         delay_seconds = int(self.autolock_var.get())
#         self.lock_timer = threading.Timer(delay_seconds, self.auto_lock_door)
#         self.lock_timer.start()
        
#         self.countdown_timer(delay_seconds)
    
#     def countdown_timer(self, remaining_seconds):
#         """Display countdown timer"""
#         if remaining_seconds > 0 and self.door_unlocked:
#             self.timer_label.configure(text=f"Auto-lock in {remaining_seconds} seconds")
#             self.root.after(1000, lambda: self.countdown_timer(remaining_seconds - 1))
#         else:
#             self.timer_label.configure(text="")
    
#     def auto_lock_door(self):
#         """Automatically lock the door"""
#         if self.door_unlocked:
#             self.lock_door()
#             self.door_unlocked = False
#             self.update_status("Door auto-locked", INFO)
#             self.timer_label.configure(text="")
    
#     def cancel_autolock(self):
#         """Cancel the auto-lock timer"""
#         if self.lock_timer:
#             self.lock_timer.cancel()
#             self.lock_timer = None
#             self.timer_label.configure(text="Auto-lock cancelled")
#             self.update_status("Auto-lock cancelled", WARNING)
    
#     def test_esp32_connection(self):
#         """Test connection to ESP32"""
#         self.esp32_ip = self.ip_entry.get()
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/status", timeout=5)
#             if response.status_code == 200:
#                 data = response.json()
#                 messagebox.showinfo("Success", f"Connected! Door status: {data['status']}")
#                 self.update_status(f"ESP32 connected - Door: {data['status']}", SUCCESS)
#             else:
#                 messagebox.showerror("Error", "Failed to connect to ESP32")
#                 self.update_status("Failed to connect to ESP32", DANGER)
#         except Exception as e:
#             messagebox.showerror("Error", f"Connection failed: {str(e)}")
#             self.update_status(f"ESP32 connection failed: {str(e)}", DANGER)
    
#     def unlock_door(self):
#         """Send unlock command to ESP32"""
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/unlock", timeout=5)
#             if response.status_code == 200:
#                 self.update_status("Door unlocked!", SUCCESS)
#                 return True
#             else:
#                 self.update_status("Failed to unlock door", DANGER)
#                 return False
#         except Exception as e:
#             self.update_status(f"Unlock error: {str(e)}", DANGER)
#             return False
    
#     def lock_door(self):
#         """Send lock command to ESP32"""
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/lock", timeout=5)
#             if response.status_code == 200:
#                 self.update_status("Door locked!", SUCCESS)
#                 self.door_unlocked = False
#                 if self.lock_timer:
#                     self.lock_timer.cancel()
#                     self.timer_label.configure(text="")
#                 return True
#             else:
#                 self.update_status("Failed to lock door", DANGER)
#                 return False
#         except Exception as e:
#             self.update_status(f"Lock error: {str(e)}", DANGER)
#             return False
    
#     def check_door_status(self):
#         """Check door status from ESP32"""
#         try:
#             response = requests.get(f"http://{self.esp32_ip}/status", timeout=5)
#             if response.status_code == 200:
#                 data = response.json()
#                 status = data['status']
#                 self.update_status(f"Door status: {status}", INFO)
#                 messagebox.showinfo("Status", f"Door is {status}")
#             else:
#                 self.update_status("Failed to get door status", DANGER)
#         except Exception as e:
#             self.update_status(f"Status check error: {str(e)}", DANGER)
    
#     def update_status(self, message, style=INFO):
#         """Update status label with color-coded style"""
#         self.status_label.configure(text=message, bootstyle=style)
#         print(f"Status: {message}")
    
#     def run(self):
#         """Start the application"""
#         self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
#         self.root.mainloop()
    
#     def on_closing(self):
#         """Handle application closing"""
#         self.recognition_active = False
#         self.stop_camera()
#         if self.lock_timer:
#             self.lock_timer.cancel()
#         self.root.destroy()

# if __name__ == "__main__":
#     try:
#         import face_recognition
#         import cv2
#         import PIL
#         import requests
#         import ttkbootstrap
#     except ImportError as e:
#         print("Missing required packages. Please install:")
#         print("pip install face-recognition opencv-python pillow requests ttkbootstrap")
#         exit(1)
    
#     app = FaceRecognitionSystem()
#     app.run()



#333333333333333333333333333333333333333333333333
# import cv2
# import face_recognition
# import numpy as np
# import tkinter as tk
# from tkinter import ttk, filedialog, messagebox
# import ttkbootstrap as ttkb
# from ttkbootstrap.constants import *
# from ttkbootstrap.tooltip import ToolTip
# import os
# import pickle
# import requests
# import threading
# from PIL import Image, ImageTk
# import json
# import time
# import logging
# import re
# from flask import Flask, request, jsonify
# import tempfile
# import shutil

# # Set up logging
# logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# class FaceRecognitionSystem:
#     def __init__(self):
#         self.root = ttkb.Window(themename="litera")
#         self.root.title("Face Recognition Door Lock System")
#         self.root.geometry("1000x700")
        
#         # Node.js server settings
#         self.nodejs_server_ip = "192.168.1.6"  # Replace with your Node.js server IP
#         self.nodejs_server_port = 3001  # Port your Node.js server is running on
        
#         # Face recognition variables
#         self.known_face_encodings = []
#         self.known_face_names = []
#         self.face_locations = []
#         self.face_encodings = []
        
#         # Camera
#         self.video_capture = None
#         self.camera_active = False
#         self.recognition_active = False
        
#         # Door lock timer
#         self.lock_timer = None
#         self.door_unlocked = False
        
#         # GUI variables
#         self.video_label = None
#         self.status_label = None
#         self.icon_cache = {}
        
#         # Flask server for mobile uploads
#         self.app = Flask(__name__)
#         self.server_thread = None
#         self.setup_flask_routes()
        
#         self.setup_gui()
#         self.load_known_faces()
        
#     def load_icon(self, icon_path, size=(20, 20)):
#         """Load and resize icon for buttons, return None if file is missing"""
#         if icon_path not in self.icon_cache:
#             if os.path.exists(icon_path):
#                 try:
#                     img = Image.open(icon_path).resize(size, Image.LANCZOS)
#                     self.icon_cache[icon_path] = ImageTk.PhotoImage(img)
#                     logging.info(f"Loaded icon: {icon_path}")
#                 except Exception as e:
#                     logging.error(f"Failed to load icon {icon_path}: {str(e)}")
#                     self.icon_cache[icon_path] = None
#             else:
#                 logging.warning(f"Icon file not found: {icon_path}")
#                 self.icon_cache[icon_path] = None
#         return self.icon_cache[icon_path]
        
#     def setup_gui(self):
#         """Set up the GUI layout"""
#         self.root.grid_rowconfigure(0, weight=1)
#         self.root.grid_columnconfigure(0, weight=0)
#         self.root.grid_columnconfigure(1, weight=1)
        
#         # Sidebar frame
#         sidebar = ttkb.Frame(self.root, padding=10, bootstyle=SECONDARY)
#         sidebar.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.W), padx=5, pady=5)
#         sidebar.grid_rowconfigure(10, weight=1)
        
#         # Main content frame
#         main_frame = ttkb.Frame(self.root, padding=10)
#         main_frame.grid(row=0, column=1, sticky=(tk.N, tk.S, tk.E, tk.W), padx=5, pady=5)
#         main_frame.grid_rowconfigure(1, weight=1)
#         main_frame.grid_columnconfigure(0, weight=1)
        
#         # Title
#         title_label = ttkb.Label(sidebar, text="Face Door Lock",
#                                 font=("Arial", 16, "bold"), bootstyle=INFO)
#         title_label.pack(pady=10, fill=tk.X)
        
#         # Node.js Server Configuration
#         ip_frame = ttkb.LabelFrame(sidebar, text="Node.js Server Config", padding=5)
#         ip_frame.pack(fill=tk.X, pady=5)
        
#         ip_subframe = ttkb.Frame(ip_frame)
#         ip_subframe.pack(fill=tk.X, padx=5, pady=5)
        
#         ttkb.Label(ip_subframe, text="IP Address:").pack(side=tk.LEFT, padx=5)
#         self.ip_entry = ttkb.Entry(ip_subframe, width=20)
#         self.ip_entry.insert(0, self.nodejs_server_ip)
#         self.ip_entry.pack(side=tk.LEFT, padx=5)
        
#         test_btn = ttkb.Button(ip_frame, text="Test", bootstyle=INFO,
#                               command=self.test_server_connection)
#         test_icon = self.load_icon("icons/test.png")
#         if test_icon:
#             test_btn.configure(image=test_icon, compound=tk.LEFT)
#         test_btn.pack(fill=tk.X, padx=5, pady=5)
#         ToolTip(test_btn, text="Test connection to Node.js server")
        
#         # Auto-lock Settings
#         autolock_frame = ttkb.LabelFrame(sidebar, text="Auto-Lock", padding=5)
#         autolock_frame.pack(fill=tk.X, pady=5)
        
#         autolock_subframe = ttkb.Frame(autolock_frame)
#         autolock_subframe.pack(fill=tk.X, padx=5, pady=5)
#         ttkb.Label(autolock_subframe, text="Seconds:").pack(side=tk.LEFT, padx=5)
#         self.autolock_var = tk.StringVar(value="10")
#         autolock_spinbox = ttkb.Spinbox(autolock_subframe, from_=5, to=60, width=5,
#                                         textvariable=self.autolock_var)
#         autolock_spinbox.pack(side=tk.LEFT, padx=5)
        
#         self.autolock_enabled = tk.BooleanVar(value=True)
#         ttkb.Checkbutton(autolock_frame, text="Enable Auto-lock",
#                         variable=self.autolock_enabled, bootstyle=INFO).pack(padx=5, pady=5)
        
#         # Face Management
#         face_frame = ttkb.LabelFrame(sidebar, text="Face Management", padding=5)
#         face_frame.pack(fill=tk.X, pady=5)
        
#         add_files_btn = ttkb.Button(face_frame, text="Add from Files", bootstyle=PRIMARY,
#                                    command=self.add_faces_from_files)
#         add_folder_icon = self.load_icon("icons/folder_add.png")
#         if add_folder_icon:
#             add_files_btn.configure(image=add_folder_icon, compound=tk.LEFT)
#         add_files_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         view_btn = ttkb.Button(face_frame, text="View Faces", bootstyle=PRIMARY,
#                               command=self.view_known_faces)
#         view_icon = self.load_icon("icons/view.png")
#         if view_icon:
#             view_btn.configure(image=view_icon, compound=tk.LEFT)
#         view_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         delete_btn = ttkb.Button(face_frame, text="Delete Face", bootstyle=PRIMARY,
#                                 command=self.delete_face)
#         delete_icon = self.load_icon("icons/delete.png")
#         if delete_icon:
#             delete_btn.configure(image=delete_icon, compound=tk.LEFT)
#         delete_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         # Mobile Upload Server Controls
#         server_frame = ttkb.LabelFrame(sidebar, text="Mobile Upload Server", padding=5)
#         server_frame.pack(fill=tk.X, pady=5)
        
#         start_server_btn = ttkb.Button(server_frame, text="Start Server", bootstyle=SUCCESS,
#                                       command=self.start_server)
#         start_server_icon = self.load_icon("icons/server_start.png")
#         if start_server_icon:
#             start_server_btn.configure(image=start_server_icon, compound=tk.LEFT)
#         start_server_btn.pack(fill=tk.X, padx=5, pady=2)
#         ToolTip(start_server_btn, text="Start server to receive mobile uploads")
        
#         stop_server_btn = ttkb.Button(server_frame, text="Stop Server", bootstyle=DANGER,
#                                      command=self.stop_server)
#         stop_server_icon = self.load_icon("icons/server_stop.png")
#         if stop_server_icon:
#             stop_server_btn.configure(image=stop_server_icon, compound=tk.LEFT)
#         stop_server_btn.pack(fill=tk.X, padx=5, pady=2)
#         ToolTip(stop_server_btn, text="Stop server for mobile uploads")
        
#         # Door Control
#         door_frame = ttkb.LabelFrame(sidebar, text="Door Control", padding=5)
#         door_frame.pack(fill=tk.X, pady=5)
        
#         unlock_btn = ttkb.Button(door_frame, text="Unlock", bootstyle=SUCCESS,
#                                 command=self.unlock_door)
#         unlock_icon = self.load_icon("icons/unlock.png")
#         if unlock_icon:
#             unlock_btn.configure(image=unlock_icon, compound=tk.LEFT)
#         unlock_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         lock_btn = ttkb.Button(door_frame, text="Lock", bootstyle=DANGER,
#                               command=self.lock_door)
#         lock_icon = self.load_icon("icons/lock.png")
#         if lock_icon:
#             lock_btn.configure(image=lock_icon, compound=tk.LEFT)
#         lock_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         status_btn = ttkb.Button(door_frame, text="Check Status", bootstyle=INFO,
#                                 command=self.check_door_status)
#         status_icon = self.load_icon("icons/status.png")
#         if status_icon:
#             status_btn.configure(image=status_icon, compound=tk.LEFT)
#         status_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         cancel_btn = ttkb.Button(door_frame, text="Cancel Auto-lock", bootstyle=WARNING,
#                                 command=self.cancel_autolock)
#         cancel_icon = self.load_icon("icons/cancel.png")
#         if cancel_icon:
#             cancel_btn.configure(image=cancel_icon, compound=tk.LEFT)
#         cancel_btn.pack(fill=tk.X, padx=5, pady=2)
        
#         # Status Frame
#         status_frame = ttkb.LabelFrame(sidebar, text="Status", padding=5)
#         status_frame.pack(fill=tk.X, pady=5, side=tk.BOTTOM)
        
#         self.status_label = ttkb.Label(status_frame, text="Ready",
#                                       font=("Arial", 12), bootstyle=INFO)
#         self.status_label.pack(pady=5)
        
#         self.timer_label = ttkb.Label(status_frame, text="",
#                                      font=("Arial", 10), bootstyle=DANGER)
#         self.timer_label.pack(pady=2)
        
#         # Camera Frame
#         camera_frame = ttkb.LabelFrame(main_frame, text="Camera Feed", padding=5)
#         camera_frame.grid(row=0, column=0, sticky=(tk.N, tk.S, tk.E, tk.W), pady=5)
#         camera_frame.grid_rowconfigure(0, weight=1)
#         camera_frame.grid_columnconfigure(0, weight=1)
        
#         self.video_label = ttkb.Label(camera_frame, text="Camera feed will appear here",
#                                      bootstyle=SECONDARY)
#         self.video_label.grid(row=0, column=0, pady=10, sticky=(tk.N, tk.S, tk.E, tk.W))
        
#         # Camera Controls
#         camera_controls = ttkb.Frame(camera_frame)
#         camera_controls.grid(row=1, column=0, pady=5, sticky=tk.E)
        
#         start_cam_btn = ttkb.Button(camera_controls, text="Start Camera", bootstyle=SUCCESS,
#                                    command=self.start_camera)
#         start_cam_icon = self.load_icon("icons/camera_start.png")
#         if start_cam_icon:
#             start_cam_btn.configure(image=start_cam_icon, compound=tk.LEFT)
#         start_cam_btn.pack(side=tk.LEFT, padx=5)
        
#         stop_cam_btn = ttkb.Button(camera_controls, text="Stop Camera", bootstyle=DANGER,
#                                   command=self.stop_camera)
#         stop_cam_icon = self.load_icon("icons/camera_stop.png")
#         if stop_cam_icon:
#             stop_cam_btn.configure(image=stop_cam_icon, compound=tk.LEFT)
#         stop_cam_btn.pack(side=tk.LEFT, padx=5)
        
#         start_rec_btn = ttkb.Button(camera_controls, text="Start Recognition", bootstyle=PRIMARY,
#                                    command=self.start_recognition)
#         start_rec_icon = self.load_icon("icons/recognition_start.png")
#         if start_rec_icon:
#             start_rec_btn.configure(image=start_rec_icon, compound=tk.LEFT)
#         start_rec_btn.pack(side=tk.LEFT, padx=5)
        
#         stop_rec_btn = ttkb.Button(camera_controls, text="Stop Recognition", bootstyle=WARNING,
#                                   command=self.stop_recognition)
#         stop_rec_icon = self.load_icon("icons/recognition_stop.png")
#         if stop_rec_icon:
#             stop_rec_btn.configure(image=stop_rec_icon, compound=tk.LEFT)
#         stop_rec_btn.pack(side=tk.LEFT, padx=5)
    
#     def setup_flask_routes(self):
#         """Set up Flask routes for receiving images from mobile app"""
#         @self.app.route('/upload_face', methods=['POST'])
#         def upload_face():
#             try:
#                 if 'image' not in request.files or 'name' not in request.form:
#                     return jsonify({"error": "Image and name are required"}), 400
                
#                 image_file = request.files['image']
#                 name = request.form['name'].strip()
                
#                 # Validate file extension
#                 if not image_file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.tiff')):
#                     return jsonify({"error": "Unsupported image format"}), 400
                
#                 # Save image to temporary file
#                 temp_dir = tempfile.mkdtemp()
#                 temp_path = os.path.join(temp_dir, image_file.filename)
#                 image_file.save(temp_path)
                
#                 # Process the image
#                 image = face_recognition.load_image_file(temp_path)
#                 face_encodings = face_recognition.face_encodings(image)
                
#                 if face_encodings:
#                     if name not in self.known_face_names:
#                         self.known_face_encodings.append(face_encodings[0])
#                         self.known_face_names.append(name)
#                         self.save_known_faces()
#                         self.root.after(0, lambda: self.update_status(f"Added face from mobile: {name}", SUCCESS))
#                         shutil.rmtree(temp_dir)  # Clean up
#                         return jsonify({"message": f"Face for {name} added successfully"}), 200
#                     else:
#                         shutil.rmtree(temp_dir)
#                         return jsonify({"error": f"Face for {name} already exists"}), 400
#                 else:
#                     shutil.rmtree(temp_dir)
#                     return jsonify({"error": "No face found in the image"}), 400
                
#             except Exception as e:
#                 if 'temp_dir' in locals():
#                     shutil.rmtree(temp_dir)
#                 self.root.after(0, lambda: self.update_status(f"Error adding face from mobile: {str(e)}", DANGER))
#                 logging.error(f"Error adding face from mobile: {str(e)}")
#                 return jsonify({"error": str(e)}), 500

#     def start_server(self):
#         """Start Flask server in a separate thread"""
#         if self.server_thread is None:
#             self.server_thread = threading.Thread(target=lambda: self.app.run(host='0.0.0.0', port=5000, debug=False))
#             self.server_thread.daemon = True
#             self.server_thread.start()
#             self.update_status("Server started for mobile uploads at 0.0.0.0:5000", SUCCESS)
#         else:
#             self.update_status("Server is already running", WARNING)

#     def stop_server(self):
#         """Stop Flask server (simplified, actual stop requires more complex handling)"""
#         if self.server_thread:
#             # Note: Flask doesn't have a clean way to stop programmatically in a thread
#             # This is a simplified approach; for production, use a proper server shutdown
#             self.server_thread = None
#             self.update_status("Server stopped (restart required for new uploads)", INFO)
    
#     def load_known_faces(self):
#         """Load known faces from pickle file"""
#         try:
#             if os.path.exists("known_faces.pkl"):
#                 with open("known_faces.pkl", "rb") as f:
#                     data = pickle.load(f)
#                     self.known_face_encodings = data["encodings"]
#                     self.known_face_names = data["names"]
#                 self.update_status(f"Loaded {len(self.known_face_names)} known faces", SUCCESS)
#             else:
#                 self.update_status("No known faces file found", WARNING)
#         except Exception as e:
#             self.update_status(f"Error loading faces: {str(e)}", DANGER)
#             logging.error(f"Error loading known faces: {str(e)}")
    
#     def save_known_faces(self):
#         """Save known faces to pickle file"""
#         try:
#             data = {
#                 "encodings": self.known_face_encodings,
#                 "names": self.known_face_names
#             }
#             with open("known_faces.pkl", "wb") as f:
#                 pickle.dump(data, f)
#             self.update_status("Faces saved successfully", SUCCESS)
#         except Exception as e:
#             self.update_status(f"Error saving faces: {str(e)}", DANGER)
#             logging.error(f"Error saving faces: {str(e)}")
    
#     def add_faces_from_files(self):
#         """Add faces from selected image files - supports PNG, JPG, JPEG, BMP, TIFF"""
#         file_paths = filedialog.askopenfilenames(title="Select face images", 
#                                                filetypes=[("Image files", "*.png *.jpg *.jpeg *.bmp *.tiff")])
#         if not file_paths:
#             return
        
#         added_count = 0
#         supported_formats = ('.png', '.jpg', '.jpeg', '.bmp', '.tiff')
        
#         for image_path in file_paths:
#             filename = os.path.basename(image_path)
#             name = os.path.splitext(filename)[0]
            
#             try:
#                 with Image.open(image_path) as img:
#                     img.verify()
#                 image = face_recognition.load_image_file(image_path)
#                 face_encodings = face_recognition.face_encodings(image)
                
#                 if face_encodings:
#                     if name not in self.known_face_names:
#                         self.known_face_encodings.append(face_encodings[0])
#                         self.known_face_names.append(name)
#                         added_count += 1
#                         self.update_status(f"Added face: {name}", SUCCESS)
#                     else:
#                         self.update_status(f"Face {name} already exists, skipping", WARNING)
#                 else:
#                     self.update_status(f"No face found in {filename}", WARNING)
#             except Exception as e:
#                 self.update_status(f"Error processing {filename}: {str(e)}", DANGER)
#                 logging.error(f"Error processing {filename}: {str(e)}")
#                 continue
        
#         if added_count > 0:
#             self.save_known_faces()
#             messagebox.showinfo("Success", f"Added {added_count} new faces successfully!")
#         else:
#             messagebox.showinfo("Info", "No new faces were added")
    
#     def delete_face(self):
#         """Delete a known face"""
#         if not self.known_face_names:
#             messagebox.showinfo("Info", "No known faces to delete")
#             return
        
#         delete_window = tk.Toplevel(self.root)
#         delete_window.title("Delete Face")
#         delete_window.geometry("300x400")
        
#         ttkb.Label(delete_window, text="Select face to delete:").pack(pady=10)
        
#         listbox = tk.Listbox(delete_window)
#         listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         for name in self.known_face_names:
#             listbox.insert(tk.END, name)
        
#         def delete_selected():
#             selection = listbox.curselection()
#             if selection:
#                 index = selection[0]
#                 name = self.known_face_names[index]
#                 if messagebox.askyesno("Confirm", f"Delete face for {name}?"):
#                     self.known_face_names.pop(index)
#                     self.known_face_encodings.pop(index)
#                     self.save_known_faces()
#                     self.update_status(f"Deleted face: {name}", SUCCESS)
#                     delete_window.destroy()
#             else:
#                 messagebox.showwarning("Warning", "Please select a face to delete")
        
#         ttkb.Button(delete_window, text="Delete Selected", bootstyle=PRIMARY,
#                    command=delete_selected).pack(pady=5)
#         ttkb.Button(delete_window, text="Cancel", bootstyle=SECONDARY,
#                    command=delete_window.destroy).pack(pady=5)
    
#     def view_known_faces(self):
#         """Show list of known faces"""
#         if not self.known_face_names:
#             messagebox.showinfo("Info", "No known faces registered")
#             return
        
#         faces_window = tk.Toplevel(self.root)
#         faces_window.title("Known Faces")
#         faces_window.geometry("300x400")
        
#         ttkb.Label(faces_window, text=f"Total faces: {len(self.known_face_names)}",
#                   font=("Arial", 12, "bold"), bootstyle=INFO).pack(pady=10)
        
#         listbox = tk.Listbox(faces_window)
#         listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
#         for i, name in enumerate(self.known_face_names, 1):
#             listbox.insert(tk.END, f"{i}. {name}")
    
#     def start_camera(self):
#         """Start camera feed"""
#         try:
#             self.video_capture = cv2.VideoCapture(0)
#             if self.video_capture.isOpened():
#                 self.camera_active = True
#                 self.update_camera_feed()
#                 self.update_status("Camera started", SUCCESS)
#             else:
#                 self.update_status("Failed to start camera", DANGER)
#                 logging.error("Failed to open camera")
#         except Exception as e:
#             self.update_status(f"Camera error: {str(e)}", DANGER)
#             logging.error(f"Camera error: {str(e)}")
    
#     def stop_camera(self):
#         """Stop camera feed"""
#         self.camera_active = False
#         self.recognition_active = False
#         if self.video_capture:
#             self.video_capture.release()
#         self.video_label.configure(image="", text="Camera stopped")
#         self.update_status("Camera stopped", INFO)
    
#     def start_recognition(self):
#         """Start face recognition process"""
#         if not self.camera_active:
#             messagebox.showwarning("Warning", "Please start the camera first")
#             return
        
#         if not self.known_face_encodings:
#             messagebox.showwarning("Warning", "No known faces registered")
#             return
        
#         self.recognition_active = True
#         recognition_thread = threading.Thread(target=self.recognition_loop)
#         recognition_thread.daemon = True
#         recognition_thread.start()
#         self.update_status("Face recognition started", SUCCESS)
    
#     def stop_recognition(self):
#         """Stop face recognition"""
#         self.recognition_active = False
#         self.update_status("Face recognition stopped", INFO)
    
#     def update_camera_feed(self):
#         """Update camera feed in GUI with face detection boxes"""
#         if self.camera_active and self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if ret:
#                 display_frame = frame.copy()
                
#                 if self.recognition_active:
#                     rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
#                     small_frame = cv2.resize(rgb_frame, (0, 0), fx=0.25, fy=0.25)
                    
#                     face_locations = face_recognition.face_locations(small_frame)
#                     face_encodings = face_recognition.face_encodings(small_frame, face_locations)
                    
#                     for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
#                         top *= 4
#                         right *= 4
#                         bottom *= 4
#                         left *= 4
                        
#                         matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
#                         name = "Unknown"
#                         color = (0, 0, 255)
                        
#                         if True in matches:
#                             face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
#                             best_match_index = np.argmin(face_distances)
#                             if matches[best_match_index] and face_distances[best_match_index] < 0.6:
#                                 name = self.known_face_names[best_match_index]
#                                 color = (0, 255, 0)
                        
#                         cv2.rectangle(display_frame, (left, top), (right, bottom), color, 2)
#                         cv2.rectangle(display_frame, (left, bottom - 35), (right, bottom), color, cv2.FILLED)
#                         font = cv2.FONT_HERSHEY_DUPLEX
#                         cv2.putText(display_frame, name, (left + 6, bottom - 6), font, 0.6, (255, 255, 255), 1)
                
#                 rgb_frame = cv2.cvtColor(display_frame, cv2.COLOR_BGR2RGB)
#                 img = Image.fromarray(rgb_frame)
#                 img = img.resize((720, 540))
#                 photo = ImageTk.PhotoImage(img)
                
#                 self.video_label.configure(image=photo, text="")
#                 self.video_label.image = photo
            
#             self.root.after(30, self.update_camera_feed)
    
#     def recognition_loop(self):
#         """Main face recognition loop"""
#         while self.recognition_active and self.camera_active and self.video_capture and self.video_capture.isOpened():
#             ret, frame = self.video_capture.read()
#             if not ret:
#                 continue
            
#             small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
#             rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
            
#             face_locations = face_recognition.face_locations(rgb_small_frame)
#             face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
            
#             for face_encoding in face_encodings:
#                 matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
#                 name = "Unknown"
                
#                 if True in matches:
#                     face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
#                     best_match_index = np.argmin(face_distances)
                    
#                     if matches[best_match_index] and face_distances[best_match_index] < 0.6:
#                         name = self.known_face_names[best_match_index]
#                         self.root.after(0, lambda n=name: self.update_status(f"Face recognized: {n}", SUCCESS))
#                         self.root.after(0, lambda n=name: self.unlock_door_with_autolock(n))
#                         time.sleep(2)
            
#             time.sleep(0.1)
    
#     def unlock_door_with_autolock(self, recognized_name):
#         """Unlock door and start auto-lock timer"""
#         if self.unlock_door():
#             self.door_unlocked = True
#             self.update_status(f"Door unlocked for {recognized_name}", SUCCESS)
            
#             if self.autolock_enabled.get():
#                 self.start_autolock_timer()
    
#     def start_autolock_timer(self):
#         """Start the auto-lock countdown timer"""
#         if self.lock_timer:
#             self.lock_timer.cancel()
        
#         try:
#             delay_seconds = int(self.autolock_var.get())
#         except ValueError:
#             delay_seconds = 10
#             self.update_status("Invalid auto-lock time, using 10 seconds", WARNING)
#             logging.warning("Invalid auto-lock time entered")
        
#         self.lock_timer = threading.Timer(delay_seconds, self.auto_lock_door)
#         self.lock_timer.start()
        
#         self.countdown_timer(delay_seconds)
    
#     def countdown_timer(self, remaining_seconds):
#         """Display countdown timer"""
#         if remaining_seconds > 0 and self.door_unlocked:
#             self.timer_label.configure(text=f"Auto-lock in {remaining_seconds} seconds")
#             self.root.after(1000, lambda: self.countdown_timer(remaining_seconds - 1))
#         else:
#             self.timer_label.configure(text="")
    
#     def auto_lock_door(self):
#         """Automatically lock the door"""
#         if self.door_unlocked:
#             self.lock_door()
#             self.door_unlocked = False
#             self.update_status("Door auto-locked", INFO)
#             self.timer_label.configure(text="")
    
#     def cancel_autolock(self):
#         """Cancel the auto-lock timer"""
#         if self.lock_timer:
#             self.lock_timer.cancel()
#             self.lock_timer = None
#             self.timer_label.configure(text="Auto-lock cancelled")
#             self.update_status("Auto-lock cancelled", WARNING)
    
#     def check_connection(self):
#         """Check if connection to Node.js server is active"""
#         self.nodejs_server_ip = self.ip_entry.get().strip()
#         if not self._is_valid_ip(self.nodejs_server_ip):
#             self.update_status("Invalid IP address format", DANGER)
#             return False
        
#         try:
#             response = requests.get(f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/status", timeout=5)
#             if response.status_code == 200:
#                 return True
#             else:
#                 self.update_status("Error Connection", DANGER)
#                 return False
#         except requests.exceptions.RequestException as e:
#             self.update_status("Error Connection", DANGER)
#             logging.error(f"Connection error: {str(e)}")
#             return False

#     def _is_valid_ip(self, ip):
#         """Basic IP address validation"""
#         pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
#         if not re.match(pattern, ip):
#             return False
#         octets = ip.split('.')
#         return all(0 <= int(o) <= 255 for o in octets)

#     def test_server_connection(self):
#         """Test connection to Node.js server with enhanced retry logic and feedback"""
#         self.nodejs_server_ip = self.ip_entry.get().strip()
#         if not self._is_valid_ip(self.nodejs_server_ip):
#             self.update_status("Invalid IP address format", DANGER)
#             messagebox.showerror("Error", "Please enter a valid IP address (e.g., 192.168.1.100)")
#             return
        
#         max_retries = 5
#         retry_delay = 3
        
#         for attempt in range(max_retries):
#             try:
#                 response = requests.get(f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/status", timeout=10)
#                 if response.status_code == 200:
#                     data = response.json()
#                     messagebox.showinfo("Success", f"Connected! Door status: {data['status']}")
#                     self.update_status(f"Node.js server connected - Door: {data['status']}", SUCCESS)
#                     return
#                 else:
#                     self.update_status("Error Connection", DANGER)
#                     messagebox.showerror("Error", f"Failed to connect to Node.js server (HTTP {response.status_code})")
#                     return
#             except requests.exceptions.ConnectionError as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Connection error: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     messagebox.showerror("Error", f"Connection failed after {max_retries} attempts. Check if Node.js server is running.")
#             except requests.exceptions.Timeout as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Timeout error: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     messagebox.showerror("Error", f"Timeout after {max_retries} attempts. Verify Node.js server connection.")
#             except requests.exceptions.RequestException as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Request error: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     messagebox.showerror("Error", f"Request failed after {max_retries} attempts. Check Node.js server configuration.")

#     def unlock_door(self):
#         """Send unlock command to Node.js server with enhanced retry logic"""
#         if not self.check_connection():
#             self.update_status("Error Connection", DANGER)
#             return False
        
#         max_retries = 5
#         retry_delay = 3
        
#         for attempt in range(max_retries):
#             try:
#                 response = requests.get(f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/unlock", timeout=10)
#                 if response.status_code == 200:
#                     self.update_status("Door unlocked!", SUCCESS)
#                     return True
#                 else:
#                     self.update_status("Failed to unlock door", DANGER)
#                     return False
#             except requests.exceptions.ConnectionError as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Connection error during unlock: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     return False
#             except requests.exceptions.Timeout as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Timeout error during unlock: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     return False
#             except requests.exceptions.RequestException as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Request error during unlock: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     return False

#     def lock_door(self):
#         """Send lock command to Node.js server with enhanced retry logic"""
#         if not self.check_connection():
#             self.update_status("Error Connection", DANGER)
#             return False
        
#         max_retries = 5
#         retry_delay = 3
        
#         for attempt in range(max_retries):
#             try:
#                 response = requests.get(f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/lock", timeout=10)
#                 if response.status_code == 200:
#                     self.update_status("Door locked!", SUCCESS)
#                     self.door_unlocked = False
#                     if self.lock_timer:
#                         self.lock_timer.cancel()
#                         self.timer_label.configure(text="")
#                     return True
#                 else:
#                     self.update_status("Failed to lock door", DANGER)
#                     return False
#             except requests.exceptions.ConnectionError as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Connection error during lock: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     return False
#             except requests.exceptions.Timeout as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Timeout error during lock: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     return False
#             except requests.exceptions.RequestException as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Request error during lock: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     return False

#     def check_door_status(self):
#         """Check door status from Node.js server with enhanced retry logic"""
#         if not self.check_connection():
#             self.update_status("Error Connection", DANGER)
#             return
        
#         max_retries = 5
#         retry_delay = 3
        
#         for attempt in range(max_retries):
#             try:
#                 response = requests.get(f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/status", timeout=10)
#                 if response.status_code == 200:
#                     data = response.json()
#                     status = data['status']
#                     self.update_status(f"Door status: {status}", INFO)
#                     messagebox.showinfo("Status", f"Door is {status}")
#                     return
#                 else:
#                     self.update_status("Error Connection", DANGER)
#                     return
#             except requests.exceptions.ConnectionError as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Connection error checking status: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     messagebox.showerror("Error", f"Connection failed after {max_retries} attempts.")
#             except requests.exceptions.Timeout as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Timeout error checking status: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     messagebox.showerror("Error", f"Timeout after {max_retries} attempts.")
#             except requests.exceptions.RequestException as e:
#                 self.update_status("Error Connection", DANGER)
#                 logging.error(f"Request error checking status: {str(e)}")
#                 if attempt < max_retries - 1:
#                     time.sleep(retry_delay)
#                 else:
#                     messagebox.showerror("Error", f"Request failed after {max_retries} attempts.")
    
#     def update_status(self, message, style=INFO):
#         """Update status label with color-coded style"""
#         try:
#             self.status_label.configure(text=message, bootstyle=style)
#         except Exception as e:
#             logging.error(f"Error updating status label: {str(e)}")
#         print(f"Status: {message}")
    
#     def run(self):
#         """Start the application"""
#         self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
#         self.root.mainloop()
    
#     def on_closing(self):
#         """Handle application closing"""
#         self.recognition_active = False
#         self.stop_camera()
#         self.stop_server()
#         if self.lock_timer:
#             self.lock_timer.cancel()
#         self.root.destroy()

# if __name__ == "__main__":
#     try:
#         import face_recognition
#         import cv2
#         import PIL
#         import requests
#         import ttkbootstrap
#         import flask
#     except ImportError as e:
#         print("Missing required packages. Please install:")
#         print("pip install face-recognition opencv-python pillow requests ttkbootstrap flask")
#         exit(1)
    
#     app = FaceRecognitionSystem()
#     app.run()
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
        self.nodejs_server_ip = "192.168.81.154"  # Replace with your Node.js server IP
        self.nodejs_server_port = 3001  # Adjust if your Express.js server uses a different port (e.g., 3000)
        
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
                
                # Validate file extension
                if not image_file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.tiff')):
                    return jsonify({"error": "Unsupported image format"}), 400
                
                # Save image to temporary file
                temp_dir = tempfile.mkdtemp()
                temp_path = os.path.join(temp_dir, image_file.filename)
                image_file.save(temp_path)
                
                # Process the image
                image = face_recognition.load_image_file(temp_path)
                face_encodings = face_recognition.face_encodings(image)
                
                if face_encodings:
                    if name not in self.known_face_names:
                        self.known_face_encodings.append(face_encodings[0])
                        self.known_face_names.append(name)
                        self.save_known_faces()
                        self.root.after(0, lambda: self.update_status(f"Added face from mobile: {name}", SUCCESS))
                        shutil.rmtree(temp_dir)  # Clean up
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
            # Note: Flask doesn't have a clean way to stop programmatically in a thread
            # This is a simplified approach; for production, use a proper server shutdown
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
            url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/status"
            response = requests.post(url, timeout=5)  # Use POST for /status
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
            messagebox.showerror("Error", "Please enter a valid IP address (e.g., 192.168.1.100)")
            return
        
        max_retries = 5
        retry_delay = 3
        
        for attempt in range(max_retries):
            try:
                url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/status"
                response = requests.post(url, timeout=10)  # Use POST for /status
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
        
        url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/elock"
        payload = {"lock": False}  # JSON data to unlock the door
        
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
        
        url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/elock"
        payload = {"lock": True}  # JSON data to lock the door
        
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
        
        url = f"http://{self.nodejs_server_ip}:{self.nodejs_server_port}/status"
        
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