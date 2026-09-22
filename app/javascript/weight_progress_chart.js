document.addEventListener("turbo:load", () => {
  const canvas = document.getElementById("weightProgressChart");

  if (!canvas) {
    return;
  }

  const labels = JSON.parse(canvas.dataset.labels);
  const weights = JSON.parse(canvas.dataset.weights);

  const existingChart = Chart.getChart(canvas);

  if (existingChart) {
    existingChart.destroy();
  }

  new Chart(canvas, {
    type: "line",

    data: {
      labels: labels,

      datasets: [
        {
          label: "重量",
          data: weights,
          tension: 0.3
        }
      ]
    },

    options: {
      responsive: true,

      scales: {
        y: {
          title: {
            display: true,
            text: "重量（kg）"
          }
        }
      }
    }
  });
});