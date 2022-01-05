const broker1 = "34.159.233.148:9092";
const broker2 = "35.242.243.122:9092";
const broker3 = "34.89.185.58:9092";

const clientConfigs = {
  clientId: "client1", // change to client2, client3 for relevant clients
  brokers: [broker1, broker2, broker3],
};

const consumerConfigs = {
  groupId: "group1",
};

module.exports = {
  clientConfigs,
  consumerConfigs,
};
