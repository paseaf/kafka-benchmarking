const broker1 = "10.1.0.21:9092";
const broker2 = "10.1.0.22:9092";
const broker3 = "10.1.0.23:9092";

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
