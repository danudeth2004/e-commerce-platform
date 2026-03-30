import { Controller } from "@hotwired/stimulus"

// ต้องโหลด Chart.js จาก layout admin ก่อน (window.Chart)
export default class extends Controller {
  static values = {
    labels: Array,
    visits: Array,
    sessions: Array,
    orders: Array
  }

  static targets = ["canvas"]

  connect() {
    if (typeof Chart === "undefined") return

    const ctx = this.canvasTarget.getContext("2d")
    if (!ctx) return

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "เข้าชมหน้า (ครั้ง)",
            data: this.visitsValue,
            borderColor: "rgb(37, 99, 235)",
            backgroundColor: "rgba(37, 99, 235, 0.08)",
            tension: 0.25,
            fill: true,
            yAxisID: "y"
          },
          {
            label: "ผู้ใช้โดยประมาณ (session ไม่ซ้ำ/วัน)",
            data: this.sessionsValue,
            borderColor: "rgb(22, 163, 74)",
            backgroundColor: "transparent",
            borderDash: [6, 4],
            tension: 0.25,
            fill: false,
            yAxisID: "y"
          },
          {
            label: "ออเดอร์ที่ชำระแล้ว",
            data: this.ordersValue,
            borderColor: "rgb(147, 51, 234)",
            backgroundColor: "rgba(147, 51, 234, 0.06)",
            tension: 0.25,
            fill: false,
            yAxisID: "y1"
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        plugins: {
          legend: {
            position: "bottom",
            labels: { boxWidth: 12, padding: 16, font: { size: 11 } }
          },
          tooltip: {
            callbacks: {
              title: (items) => (items[0] ? `วันที่ ${items[0].label}` : "")
            }
          }
        },
        scales: {
          x: {
            grid: { display: false },
            ticks: { maxRotation: 45, minRotation: 0, font: { size: 10 } }
          },
          y: {
            type: "linear",
            position: "left",
            title: { display: true, text: "เข้าชม / ผู้ใช้ (ครั้ง)" },
            beginAtZero: true,
            ticks: { precision: 0 }
          },
          y1: {
            type: "linear",
            position: "right",
            title: { display: true, text: "ออเดอร์ที่ชำระแล้ว" },
            beginAtZero: true,
            grid: { drawOnChartArea: false },
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
