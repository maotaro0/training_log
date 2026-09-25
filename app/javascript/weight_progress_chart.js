document.addEventListener("turbo:load", () => {
  const canvas = document.getElementById("weightProgressChart");

  if (!canvas) {
    return;
  }

  const labels = JSON.parse(canvas.dataset.labels || "[]");
  const weights = JSON.parse(canvas.dataset.weights || "[]");

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

          borderColor: "#38bdf8",
          backgroundColor: "rgba(56, 189, 248, 0.12)",

          borderWidth: 2,

          fill: true,

          tension: 0.3,

          pointRadius: 4,
          pointHoverRadius: 6
        }
      ]
    },

    options: {
      responsive: true,

      maintainAspectRatio: false,

      plugins: {
        legend: {
          display: false
        }
      },

      scales: {
        x: {
          grid: {
            display: false
          },

          ticks: {
            color: "#94a3b8"
          }
        },

        y: {
          grid: {
            color: "rgba(148, 163, 184, 0.18)"
          },

          ticks: {
            color: "#94a3b8"
          },

          title: {
            display: true,
            text: "重量（kg）",
            color: "#94a3b8"
          }
        }
      }
    }
  });
});