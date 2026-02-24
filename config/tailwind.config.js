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
        "Primary-color": "#FF1493",
        "Secondary-color": "#FF69B4",
        "Tertiary-color": "#FFE4E1",

        //text colors
        "text-primary": "#212429",

        //icon colors
        "icon-onPrimaryAction": "#FFFFFF",
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
