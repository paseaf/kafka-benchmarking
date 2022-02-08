const os = require("os");
const clientConfigs = {
  clientId: os.hostname(),
  brokers: ["10.1.0.21:9092", "10.1.0.22:9092", "10.1.0.23:9092"],
};

const consumerConfigs = {
  groupId: "benchmarkgroup",
};

const TOPIC = "benchmark";

module.exports = {
  clientConfigs,
  consumerConfigs,
  TOPIC,
};
