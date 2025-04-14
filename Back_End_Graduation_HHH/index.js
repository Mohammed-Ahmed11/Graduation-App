const express = require("express");
const app = express();
const cors = require("cors");

app.use(express.json());
app.use(cors());
const db = require("./models");

//Routers

async function run() {
  try {
    // Connect the client to the server	(optional starting in v4.7)
    await client.connect();
    // Send a ping to confirm a successful connection
    await client.db("admin").command({ ping: 1 });
    console.log(
      "Pinged your deployment. You successfully connected to MongoDB!"
    );
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}
run().catch(console.dir);

// const postRouter = require("./routes/Posts");
// app.use("/posts", postRouter);

// const commentsRouter = require("./routes/Comments");
// app.use("/comments", commentsRouter);

// const usersRouter = require("./routes/Users");
// app.use("/auth", usersRouter);

// db.sequelize.sync().then(() => {
app.listen(3001, () => {
  console.log("connected on port 3001");
});
// });
