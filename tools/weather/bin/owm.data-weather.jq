(
  .weather[0] |
    ("weather,general \(.main)"),
    ("weather,description \(.description)")
),

(
  .main |
    ("temperature \(.temp)"),
    ("temperature,feels \(.feels_like)"),
    ("temperature,minimum \(.temp_min)"),
    ("temperature,maximum \(.temp_max)"),
    ("pressure \(.pressure)"),
    ("humidity \(.humidity)")
),

(
  .wind |
    ("wind,speed \(.speed)"),
    ("wind,direction \(.deg)")
),

(
  .clouds |
    ("clouds,percent \(.all)")
),

("visibility \(.visibility)"),
("time \(.dt)"),
("time,zone \(.timezone)"),
("name \(.name)")
