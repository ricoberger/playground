const { trace } = require("@opentelemetry/api");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const {
  ConsoleSpanExporter,
  SimpleSpanProcessor,
} = require("@opentelemetry/sdk-trace-base");
const {
  OTLPTraceExporter,
} = require("@opentelemetry/exporter-trace-otlp-proto");
const { ATTR_SERVICE_NAME } = require("@opentelemetry/semantic-conventions");
const {
  ExpressInstrumentation,
} = require("@opentelemetry/instrumentation-express");
const { HttpInstrumentation } = require("@opentelemetry/instrumentation-http");
const { ZoneContextManager } = require("@opentelemetry/context-zone");
const { B3Propagator } = require("@opentelemetry/propagator-b3");
const {
  CompositePropagator,
  W3CTraceContextPropagator,
} = require("@opentelemetry/core");
const { resourceFromAttributes } = require("@opentelemetry/resources");

function setupTracing(serviceName) {
  const provider = new NodeTracerProvider({
    resource: resourceFromAttributes({
      [ATTR_SERVICE_NAME]: serviceName,
    }),
    spanProcessors: [
      new SimpleSpanProcessor(new ConsoleSpanExporter()),
      new SimpleSpanProcessor(new OTLPTraceExporter()),
    ],
  });

  registerInstrumentations({
    tracerProvider: provider,
    instrumentations: [new HttpInstrumentation(), new ExpressInstrumentation()],
  });

  provider.register({
    contextManager: new ZoneContextManager(),
    propagator: new CompositePropagator({
      propagators: [new B3Propagator(), new W3CTraceContextPropagator()],
    }),
  });

  return trace.getTracer(serviceName);
}

exports.setupTracing = setupTracing;
