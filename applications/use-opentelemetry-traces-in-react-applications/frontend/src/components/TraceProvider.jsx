import {
  ConsoleSpanExporter,
  SimpleSpanProcessor,
  WebTracerProvider,
} from "@opentelemetry/sdk-trace-web";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { DocumentLoadInstrumentation } from "@opentelemetry/instrumentation-document-load";
import { FetchInstrumentation } from "@opentelemetry/instrumentation-fetch";
import { ZoneContextManager } from "@opentelemetry/context-zone";
import { registerInstrumentations } from "@opentelemetry/instrumentation";
import { B3Propagator } from "@opentelemetry/propagator-b3";
import {
  CompositePropagator,
  W3CTraceContextPropagator,
} from "@opentelemetry/core";
import { resourceFromAttributes } from "@opentelemetry/resources";
import { ATTR_SERVICE_NAME } from "@opentelemetry/semantic-conventions";

const provider = new WebTracerProvider({
  resource: resourceFromAttributes({
    [ATTR_SERVICE_NAME]: "react-app",
  }),
  spanProcessors: [
    new SimpleSpanProcessor(new ConsoleSpanExporter()),
    new SimpleSpanProcessor(
      new OTLPTraceExporter({
        url: "http://localhost:3000/v1/traces",
      }),
    ),
  ],
});

provider.register({
  contextManager: new ZoneContextManager(),
  propagator: new CompositePropagator({
    propagators: [new B3Propagator(), new W3CTraceContextPropagator()],
  }),
});

registerInstrumentations({
  instrumentations: [
    new DocumentLoadInstrumentation(),
    new FetchInstrumentation({
      propagateTraceHeaderCorsUrls: ["http://localhost:3000"],
      clearTimingResources: true,
    }),
  ],
});

export const webTracer = provider.getTracer("web-tracer");

export function TraceProvider(props) {
  return <>{props.children}</>;
}
