import { Controller } from "@hotwired/stimulus"

// กราฟยอดเงิน (บาท) — ต้องโหลด Chart.js จาก layout admin ก่อน
export default class RevenueChartController extends Controller {
  static values = {
    labels: Array,
    gmv: Array,
    platform: Array,
    seller: Array
  }

  static targets = ["canvas"]

  connect() {
    if (typeof Chart === "undefined") return

    const ctx = this.canvasTarget.getContext("2d")
    if (!ctx) return

    const fmt = (v) =>
      new Intl.NumberFormat("th-TH", { style: "currency", currency: "THB", maximumFractionDigits: 2 }).format(v)

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "ยอดขายชำระแล้ว (GMV)",
            data: this.gmvValue,
            borderColor: "rgb(37, 99, 235)",
            backgroundColor: "rgba(37, 99, 235, 0.06)",
            tension: 0.25,
            fill: true,
            yAxisID: "y"
          },
          {
            label: "ค่าธรรมเนียมแพลตฟอร์ม (10%)",
            data: this.platformValue,
            borderColor: "rgb(234, 88, 12)",
            backgroundColor: "transparent",
            tension: 0.25,
            fill: false,
            yAxisID: "y"
          },
          {
            label: "ยอดส่งให้ร้านค้า (รวม)",
            data: this.sellerValue,
            borderColor: "rgb(22, 163, 74)",
            backgroundColor: "transparent",
            borderDash: [6, 4],
            tension: 0.25,
            fill: false,
            yAxisID: "y"
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
            labels: { boxWidth: 12, padding: 14, font: { size: 11 } }
          },
          tooltip: {
            callbacks: {
              title: (items) => (items[0] ? `วันที่ ${items[0].label}` : ""),
              label: (ctx) => `${ctx.dataset.label}: ${fmt(ctx.parsed.y)}`
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
            title: { display: true, text: "บาท (THB)" },
            beginAtZero: true,
            ticks: {
              callback: (v) => fmt(v)
            }
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
