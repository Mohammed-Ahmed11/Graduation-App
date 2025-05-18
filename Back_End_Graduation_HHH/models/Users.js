module.exports = (sequelize, DataTypes) => {
  const Users = sequelize.define("Users", {
    firstName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    secoundName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    profile_image: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  });
  Users.associate = (models) => {
    Users.hasMany(models.Users, {
      foreignKey: "UserID",
      onDelete: "CASCADE",
    });
  };
  return Users;
};
