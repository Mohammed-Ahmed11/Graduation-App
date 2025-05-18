const express = require("express");
const router = express.Router();
const { Users } = require("../models");
const bcrypt = require("bcrypt");

const { sign } = require("jsonwebtoken");
// router.get("/byId/:id",async(req,res)=>{
//     const id = req.params.id;
//     const post = await Posts.findByPk(id);
//     res.json(post);
// });

router.post("/", async (req, res) => {
  const { fname, lname, email, password, pImage } = req.body;

  // check if the user existing
  try {
    const existingUser = await Users.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "Email is already registered",
      });
    }

    // wait for the hash to complete
    const hash = await bcrypt.hash(password, 10);
    const normalizedEmail = email.trim().toLowerCase();

    // wait for the database operation to complete
    const newUser = await Users.create({
      firstName: fname,
      secoundName: lname,
      email: normalizedEmail,
      password: hash,
      profile_image: pImage,
    });

    res.json({ success: true, message: "User registered successfully" });
  } catch (error) {
    // error handling
    console.error("Registration error:", error);
    res.status(500).json({
      success: false,
      message: "Registration failed",
      error: error.message,
    });
  }
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const user = await Users.findOne({ where: { email: email } });
  !user
    ? res.json({ error: "not fund" })
    : bcrypt.compare(password, user.password).then((match) => {
        !match
          ? res.json({ error: "wrong password" })
          : res.json({
              success: sign(
                {
                  email: user.email,
                  username: user.firstName + " " + user.secoundName,
                  id: user.id,
                },
                "important"
              ),
            });
      });
});

router.post("/change", async (req, res) => {
  const { email, password, npassword } = req.body;
  const hash = await bcrypt.hash(npassword, 10);

  try {
    const user = await Users.findOne({ where: { email: email } });

    if (!user) {
      res.json({ error: "User not fund" });
    }
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ error: "Old password is incorrect" });
    }

    const hash = await bcrypt.hash(npassword, 10);
    await Users.update({ password: hash }, { where: { email } });
    res.json({ success: true, message: "Password updated successfully" });
  } catch (error) {
    // error handling
    console.error("Change password error:", error);
    res.status(500).json({
      success: false,
      message: "Change password failed",
      error: error.message,
    });
  }
});

module.exports = router;
