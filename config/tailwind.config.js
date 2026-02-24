module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/tailwind/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        //background colors
        "bg-surface": "#FCFCFC",
        "bg-canvas": "#F5F5F4",
        "bg-canvas-mobile": "#FFFFFF",
        "bg-surface-mobile": "#F7F7F7",
        "bg-tooltips": "#1A1A1A",
        "bg-table-cell": "#FFFFFF",
        "bg-table-header": "#E5E5E5",
        "bg-input": "#FFFFFF",
        "bg-input-disable": "#E5E5E5",
        "bg-highlight": "#FFEFCC",
        "bg-accent": "#E5E5E5",
        "bg-sidebar-active": "#025A64",
        "bg-sidebar-surface": "#040335",
        "bg-action-primary": "#FFB610",
        "bg-action-secondary": "#00B092",
        "bg-semantic-info": "#F1F8FF",
        "bg-semantic-success": "#F2FAF6",
        "bg-semantic-danger": "#FEF2F2",
        "bg-semantic-warning": "#FFF9EE",

        //text colors
        "text-neutral": "#333333",
        "text-primary": "#00B092",
        "text-onActionPrimary": "#FFFFFF",
        "text-onTooltips": "#FFFFFF",
        "text-subtle": "#999999",
        "text-semantic-info": "#3A70E2",
        "text-semantic-danger": "#EC2D30",
        "text-semantic-warning": "#FE9B0E",
        "text-semantic-success": "#0C9D61",
        "text-onSidebar-neutral": "#CCCCCC",
        "text-onSidebar-accent": "#FFFFFF",

        //border colors
        "border-subtle": "#E5E5E5",
        "border-strong": "#CCCCCC",
        "border-primary": "#FFB610",
        "border-sidebar-divider": "#4D4D4D",
        "border-semantic-info-subtle": "#BDDDFF",
        "border-semantic-danger-subtle": "#FFCCD2",
        "border-semantic-success-subtle": "#C0E5D1",
        "border-semantic-warning-subtle": "#FFEAB3",
        "border-semantic-info-strong": "#3A70E2",
        "border-semantic-danger-strong": "#EC2D30",
        "border-semantic-success-strong": "#0C9D61",
        "border-semantic-warning-strong": "#FE9B0E",

        //icon colors
        "icon-subtle": "#808080",
        "icon-onPrimaryAction": "#FFFFFF",
        "icon-semantic-info": "#3A70E2",
        "icon-semantic-danger": "#EC2D30",
        "icon-semantic-success": "#0C9D61",
        "icon-semantic-warning": "#FE9B0E",
      },
      boxShadow: {
        "elevation-1":
          "0 2px 4px 0 rgba(0,0,0,0.04), 0 1px 1px 0 rgba(0,0,0,0.02)",
        "elevation-2":
          "0 1px 4px 0 rgba(0,0,0,0.04), 0 4px 10px 0 rgba(0,0,0,0.08)",
        "elevation-3":
          "0 2px 20px 0 rgba(0,0,0,0.04), 0 8px 32px 0 rgba(0,0,0,0.08)",
        "elevation-4":
          "0 8px 20px 0 rgba(0,0,0,0.06), 0 24px 60px 0 rgba(0,0,0,0.12)",
      },
      fontSize: {
        caption: ["12px", "18px"],
        body: ["14px", "22px"],
        subtitle: ["16px", "24px"],
        title: ["18px", "26px"],
        h3: ["20px", "28px"],
        h2: ["24px", "32px"],
        h1: ["30px", "38px"],
      },
      fontWeight: {
        regular: "400",
        medium: "500"
      },
    },
  },
};
