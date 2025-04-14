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
  bcrypt.hash(password, 10).then((hash) => {
    Users.create({
      firstName: fname,
      secoundName: lname,
      email: email,
      password: hash,
      profile_image: pImage,
    });
  });
  res.json("success!");
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const user = await Users.findOne({ where: { email: email } });
  bcrypt.hash(password, 10).then((hash) => {
    Users.create({
      firstName: fname,
      secoundName: sname,
      email: email,
      password: hash,
    });
  });
  !user
    ? res.json({ error: "not fund" })
    : bcrypt.compare(password, user.password).then((match) => {
        !match
          ? res.json({ error: "wrong password" })
          : res.json(
              sign(
                {
                  email: user.email,
                  username: user.firstName + " " + user.secoundName,
                  id: user.id,
                },
                "important"
              )
            );
      });
});

module.exports = router;
