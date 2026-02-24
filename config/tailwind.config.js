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
        // background colors
        // "bg-surface": "#FCFCFC",
        // "bg-canvas": "#F5F5F4",
        // "bg-canvas-mobile": "#FFFFFF",
        // "bg-surface-mobile": "#F7F7F7",
        // "bg-tooltips": "#1A1A1A",
        // "bg-table-cell": "#FFFFFF",
        // "bg-table-header": "#E5E5E5",
        "Primary-color": "#FF1493",
        "Secondary-color": "#FF69B4",
        "Tertiary-color": "#FFE4E1",
        // "bg-input-disable": "#E5E5E5",
        // "bg-highlight": "#FFEFCC",
        // "bg-accent": "#E5E5E5",
        // "bg-sidebar-active": "#025A64",
        // "bg-sidebar-surface": "#040335",
        // "bg-action-primary": "#FFB610",
        // "bg-action-secondary": "#00B092",
        // "bg-semantic-info": "#F1F8FF",
        // "bg-semantic-success": "#F2FAF6",
        // "bg-semantic-danger": "#FEF2F2",
        // "bg-semantic-warning": "#FFF9EE",

        //text colors
        "text-primary": "#212429",
        // "text-onActionPrimary": "#FFFFFF",
        // "text-onTooltips": "#FFFFFF",
        // "text-subtle": "#999999",
        // "text-semantic-info": "#3A70E2",
        // "text-semantic-danger": "#EC2D30",
        // "text-semantic-warning": "#FE9B0E",
        // "text-semantic-success": "#0C9D61",
        // "text-onSidebar-neutral": "#CCCCCC",
        // "text-onSidebar-accent": "#FFFFFF",

        //border colors
        // "border-subtle": "#E5E5E5",
        // "border-strong": "#CCCCCC",
        // "border-primary": "#FFB610",
        // "border-sidebar-divider": "#4D4D4D",
        // "border-semantic-info-subtle": "#BDDDFF",
        // "border-semantic-danger-subtle": "#FFCCD2",
        // "border-semantic-success-subtle": "#C0E5D1",
        // "border-semantic-warning-subtle": "#FFEAB3",
        // "border-semantic-info-strong": "#3A70E2",
        // "border-semantic-danger-strong": "#EC2D30",
        // "border-semantic-success-strong": "#0C9D61",
        // "border-semantic-warning-strong": "#FE9B0E",

        //icon colors
        // "icon-subtle": "#808080",
        "icon-onPrimaryAction": "#FFFFFF",
        // "icon-semantic-info": "#3A70E2",
        // "icon-semantic-danger": "#EC2D30",
        // "icon-semantic-success": "#0C9D61",
        // "icon-semantic-warning": "#FE9B0E",
      },
      boxShadow: {
        pinkGlow: "0 0 6px 0 rgba(255, 105, 180, 0.2)",
      },
      fontSize: {
        xs: ["12px", { lineHeight: "auto" }],
        sm: ["14px", { lineHeight: "auto" }],
        base: ["16px", { lineHeight: "auto" }],
        xl: ["20px", { lineHeight: "auto" }],
        "2xl": ["24px", { lineHeight: "auto" }],
      },
      fontWeight: {
        regular: "400",
        semibold: "600",
      },
    },
  },
};
