# Helm Charts

This is a collection of [helm charts](https://helm.sh) published by [Skookum](https://skookum.com).

## Getting Started

```bash
helm repo add skookum "https://charts.cloud.skookum.com"
```

## Creating a Chart

First, create a new chart directory:

```bash
cd charts
helm create <chart-name>
```

Then modify `publish.yaml` to include the name of your new chart.

## Publishing Chart Updates

Whenever a chart is modified, you will also need to bump its `version` key in Chart.yaml. Changes to the `master` branch are automatically published to the [Skookum chart repository](https://charts.cloud.skookum.com).
