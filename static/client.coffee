PlayerCtrl = ($scope) ->
  $scope.player =
    name: "New Player"
    email: null

  console.log "Getting player"
  $.get '/api/users/me', (data) ->
    console.log "Got player: #{JSON.stringify data}"
    $scope.player = data

$("#playerDataSave").click ->
  console.log "Saving player: #{JSON.stringify $scope.player}"
  $.put '/api/users/#{$scope.player.user_id}', $scope.player, ->
    alert "FAGGOT"