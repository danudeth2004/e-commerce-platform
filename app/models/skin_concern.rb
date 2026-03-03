class SkinConcern
  DATA = [
    { id: 1, key: "acne_skin",        label: "ผิวเป็นสิว" },
    { id: 2, key: "oily_skin",        label: "ผิวมัน" },
    { id: 3, key: "dry_skin",         label: "ผิวแห้ง" },
    { id: 4, key: "combination_skin", label: "ผิวผสม" },
    { id: 5, key: "sensitive_skin",   label: "ผิวแพ้ง่าย" },
    { id: 6, key: "dull_skin",        label: "ผิวหมองคล้ำ" },
    { id: 7, key: "dark_spots_skin",       label: "รอยดำ" },
    { id: 8, key: "red_spots_skin",        label: "รอยแดง" }
  ].freeze

  def self.all
    DATA
  end
end
