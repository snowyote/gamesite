siteApp = angular.module 'siteApp', []
siteApp.factory 'Player', ->
  name: "New Player"
  mail_hash: '00000000000000000000000000000000'

PlayerCtrl = ($scope, Player) ->
  $scope.player = Player

  $scope.avatar = (hash) ->
    "http://www.gravatar.com/avatar/#{hash}?d=mm"

  $.get '/api/users/me', (data) ->
    $scope.$apply ->
      $scope.player = data

  $scope.saveUser = ->
    $.ajax
      url: "/api/users/#{$scope.player.id}"
      type: "PUT"
      data: $scope.player
