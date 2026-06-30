# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NeighborHub.Repo.insert!(%NeighborHub.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias NeighborHub.Repo
alias NeighborHub.Accounts.User
alias NeighborHub.Events.Event

# Helper to hash passwords the same way your User schema does
hash = fn pw -> Base.encode64(:crypto.hash(:sha256, pw)) end

users = [
  %{name: "Maya Chen",     email: "maya@neighborhub.dev",     password_hash: hash.("password123")},
  %{name: "Diego Alvarez", email: "diego@neighborhub.dev",    password_hash: hash.("password123")},
  %{name: "Priya Nair",    email: "priya@neighborhub.dev",    password_hash: hash.("password123")},
  %{name: "Sam Whitfield", email: "sam@neighborhub.dev",      password_hash: hash.("password123")}
]

inserted_users =
  Enum.map(users, fn attrs ->
    Repo.insert!(struct(User, attrs))
  end)

[maya, diego, priya, sam] = inserted_users

events = [
  %{
    title: "Saturday Morning Stoop Sale",
    description: "Clearing out the garage — books, vinyl records, kids' bikes, and a working espresso machine. Cash only, come early for the good stuff.",
    location: "412 Maple Street",
    date: ~N[2026-07-04 09:00:00],
    user_id: maya.id
  },
  %{
    title: "Community Garden Cleanup",
    description: "Bring gloves if you have them — we'll have extras. Coffee and donuts provided. All ages welcome, this is a great one for kids.",
    location: "Oakwood Community Garden",
    date: ~N[2026-07-06 10:00:00],
    user_id: diego.id
  },
  %{
    title: "Block Party Potluck",
    description: "Annual summer block party! Bring a dish to share. We'll have a grill going and a playlist running until sunset. Folding chairs encouraged.",
    location: "Elm Street (between 3rd and 4th)",
    date: ~N[2026-07-12 17:00:00],
    user_id: priya.id
  },
  %{
    title: "Evening Badminton at the Park",
    description: "Casual games, all skill levels. We have two extra rackets if you don't have your own.",
    location: "Riverside Park, Court 2",
    date: ~N[2026-07-08 18:30:00],
    user_id: sam.id
  },
  %{
    title: "Lost Cat: Help Us Look",
    description: "Our orange tabby Biscuit has been missing since Tuesday. Meeting at the corner to split up and search nearby yards and alleys.",
    location: "Corner of Birch & 5th",
    date: ~N[2026-07-02 19:00:00],
    user_id: maya.id
  },
  %{
    title: "Free Little Library Build Day",
    description: "Building a free library box for the corner of 6th and Pine. Basic carpentry, no experience needed — we'll teach you as we go.",
    location: "6th & Pine corner lot",
    date: ~N[2026-07-15 13:00:00],
    user_id: diego.id
  }
]

Enum.each(events, fn attrs ->
  Repo.insert!(struct(Event, attrs))
end)

IO.puts("Seeded #{length(inserted_users)} users and #{length(events)} events.")
