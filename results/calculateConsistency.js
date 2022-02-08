const { parse } = require("csv-parse/sync");
const fs = require("fs");
const dir = "client1-client1";
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

for (let configId = 0; configId < 9; configId++) {
  const producerRows = producerRowsOfConfig[configId];
  const consumerRows = consumerRowsOfConfig[configId];

  console.log(`Results for configId ${configId}`);

  const numOfMessagesSent = producerRows.length;
  const numOfSuccessfulRequests = producerRows.filter(
    (row) => row.success === "true"
  ).length;
  const numOfMessagesReceived = consumerRows.length;
  const totalPositionOffsets = producerRows.reduce(
    (accum, consumerRow, curIdx) =>
      accum +
      Math.abs(Number.parseInt(consumerRow.id) - consumerRows[curIdx].id),
    0
  );

  const results = {};
  results.yield = numOfSuccessfulRequests / numOfMessagesSent;
  results.harvest = numOfMessagesReceived / numOfMessagesSent;
  results.order = totalPositionOffsets;
  results.duplication = numOfMessagesReceived - new Set(consumerRows).size;
  console.log(results);
  console.log("=====", "\n");
}
