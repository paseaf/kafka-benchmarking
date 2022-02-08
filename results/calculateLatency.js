const { parse } = require("csv-parse/sync");
const fs = require("fs");
const sender = "client3";
const receiver = "client3";
const dir = sender + "-" + receiver;
const producerLog = fs.readFileSync(dir + "/producer-run1.csv");
const consumerLog = fs.readFileSync(dir + "/consumer-run1.csv");

const producerLogParsed = parse(producerLog, {
  columns: true,
  skip_empty_lines: true,
});
const consumerLogParsed = parse(consumerLog, {
  columns: true,
  skip_empty_lines: true,
});
const producerRowsOfConfig = Array.of(9);
const consumerRowsOfConfig = Array.of(9);

producerRowsOfConfig[0] = producerLogParsed.filter(
  (row) => row.acks === "-1" && row.maxInFlightRequests === "null"
);
consumerRowsOfConfig[0] = consumerLogParsed.filter(
  (row) => row.acks === "-1" && row.maxInFlightRequests === "null"
);

producerRowsOfConfig[1] = producerLogParsed.filter(
  (row) => row.acks === "-1" && row.maxInFlightRequests === "1"
);
consumerRowsOfConfig[1] = consumerLogParsed.filter(
  (row) => row.acks === "-1" && row.maxInFlightRequests === "1"
);

producerRowsOfConfig[2] = producerLogParsed.filter(
  (row) => row.acks === "-1" && row.maxInFlightRequests === "10"
);
consumerRowsOfConfig[2] = consumerLogParsed.filter(
  (row) => row.acks === "-1" && row.maxInFlightRequests === "10"
);

producerRowsOfConfig[3] = producerLogParsed.filter(
  (row) => row.acks === "0" && row.maxInFlightRequests === "null"
);
consumerRowsOfConfig[3] = consumerLogParsed.filter(
  (row) => row.acks === "0" && row.maxInFlightRequests === "null"
);

producerRowsOfConfig[4] = producerLogParsed.filter(
  (row) => row.acks === "0" && row.maxInFlightRequests === "1"
);
consumerRowsOfConfig[4] = consumerLogParsed.filter(
  (row) => row.acks === "0" && row.maxInFlightRequests === "1"
);

producerRowsOfConfig[5] = producerLogParsed.filter(
  (row) => row.acks === "0" && row.maxInFlightRequests === "10"
);
consumerRowsOfConfig[5] = consumerLogParsed.filter(
  (row) => row.acks === "0" && row.maxInFlightRequests === "10"
);

producerRowsOfConfig[6] = producerLogParsed.filter(
  (row) => row.acks === "1" && row.maxInFlightRequests === "null"
);
consumerRowsOfConfig[6] = consumerLogParsed.filter(
  (row) => row.acks === "1" && row.maxInFlightRequests === "null"
);

producerRowsOfConfig[7] = producerLogParsed.filter(
  (row) => row.acks === "1" && row.maxInFlightRequests === "1"
);
consumerRowsOfConfig[7] = consumerLogParsed.filter(
  (row) => row.acks === "1" && row.maxInFlightRequests === "1"
);

producerRowsOfConfig[8] = producerLogParsed.filter(
  (row) => row.acks === "1" && row.maxInFlightRequests === "10"
);
consumerRowsOfConfig[8] = consumerLogParsed.filter(
  (row) => row.acks === "1" && row.maxInFlightRequests === "10"
);

fs.writeFileSync(
  `${dir}/latency_results.csv`,
  "sender,receiver,configId, messageId, latencyInMs\n"
);

for (let configId = 0; configId < 9; configId++) {
  const consumerRows = consumerRowsOfConfig[configId];
  console.log(`Calculating latency for configId ${configId}`);

  for (const consumerRow of consumerRows) {
    const latencyInMs = consumerRow.receiveTime - consumerRow.sendTime;
    fs.appendFileSync(
      `${dir}/latency_results.csv`,
      `${sender},${receiver},${configId},${consumerRow.id},${latencyInMs}\n`
    );
  }

  console.log("Done");
}
