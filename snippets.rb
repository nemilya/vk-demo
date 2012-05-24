SNIPPETS = {}

SNIPPETS[:user_settings] = <<USER_SETTINGS
@app.get_user_settings
USER_SETTINGS

SNIPPETS[:groups] = <<GROUPS
@app.groups.get(extended: 1).tap(&:shift).map do |group|
  "\#{group[:name]} (\#{group[:screen_name]})"
end
GROUPS

SNIPPETS[:friends] = <<FRIENDS
@app.friends.get(fields: 'first_name,last_name', count: 7) do |friend|
  "\#{friend[:first_name]} \#{friend[:last_name]}"
end
FRIENDS

SNIPPETS[:audio] = <<AUDIO
@app.audio.get(count: 7) do |audio|
  "\#{audio[:artist]}: \#{audio[:title]}"
end
AUDIO

SNIPPETS[:wall] = <<WALL
@app.wall.get(count: 7).tap(&:shift).map do |wall_item|
  "\#{wall_item[:text]}"
end
WALL
