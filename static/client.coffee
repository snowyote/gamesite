siteApp = angular.module 'siteApp', []
siteApp.factory 'Player', ->
  name: "New Player"
  mail_hash: '00000000000000000000000000000000'

PlayerCtrl = ($scope, Player) ->
  $scope.player = Player

  $scope.avatar = (hash) ->
    "http://www.gravatar.com/avatar/#{hash}?d=mm&f=y"

  console.log "loading user"
  $.get '/api/users/me', (data) ->
    console.log "Got player: #{JSON.stringify data}"
    $scope.$apply ->
      $scope.player = data

$("#playerDataSave").click ->
  console.log "Saving player: #{JSON.stringify $scope.player}"
  $.put '/api/users/#{$scope.player.user_id}', $scope.player, ->
    alert "SUCCESS PATROL"