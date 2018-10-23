k-screen = document.get-element-by-id 'kotodama-screen'
k-screen.class-list.remove 'activated'
set-timeout !->
  k-screen.class-list.add 'exist'
, 200
