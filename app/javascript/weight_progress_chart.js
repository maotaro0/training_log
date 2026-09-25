document.addEventListener("turbo:load", () => {
  const canvas = document.getElementById("weightProgressChart");

  if (!canvas) {
    return;
  }

  const labels = JSON.parse(
    canvas.dataset.labels || "[]"
  );

  const weights = JSON.parse(
    canvas.dataset.weights || "[]"
  );

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
          data: weights,

          borderColor: "#2ea8ff",

          backgroundColor:
            "rgba(46, 168, 255, 0.08)",

          borderWidth: 3,

          fill: true,

          tension: 0.25,

          pointRadius: 3,

          pointHoverRadius: 6,

          pointBackgroundColor: "#e9f7ff",

          pointBorderColor: "#2ea8ff",

          pointBorderWidth: 2
        }
      ]
    },

    options: {
      responsive: true,

      maintainAspectRatio: false,

      interaction: {
        intersect: false,
        mode: "index"
      },

      plugins: {
        legend: {
          display: false
        },

        tooltip: {
          displayColors: false,

          callbacks: {
            label: (context) => {
              return `${context.parsed.y} kg`;
            }
          }
        }
      },

      scales: {
        x: {
          border: {
            color: "#425364"
          },

          grid: {
            color:
              "rgba(87, 108, 127, 0.16)"
          },

          ticks: {
            color: "#8899a8",

            font: {
              size: 10
            }
          }
        },

        y: {
          border: {
            display: false
          },

          grid: {
            color:
              "rgba(87, 108, 127, 0.20)"
          },

          ticks: {
            color: "#8899a8",

            font: {
              size: 10
            },

            callback: (value) => {
              return `${value}`;
            }
          }
        }
      }
    }
  });
});