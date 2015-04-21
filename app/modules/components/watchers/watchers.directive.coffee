WatchersDirective = ($rootscope, confirm, repo, qqueue, $translate) ->
    # You have to include a div with the tg-lb-watchers directive in the page
    # where use this directive

    link = (scope, el, attrs, ctrl) ->
        getTitle: () ->
            console.log "getTitle"
            if @.isEditable(project, requiredPerm) and watchers?.length == 0
                return $translate.instant("COMMON.WATCHERS.ADD")
            else
                return $translate.instant("COMMON.WATCHERS.TITLE")

        scope.$on "watcher:added", (ctx, watcherId) ->
            watchers = _.clone(scope.watched.watchers, false)
            watchers.push(watcherId)
            watchers = _.uniq(watchers)
            ctrl.saveWatchers(scope.watched, watchers)

        scope.$watch "watched", (watched) ->
            console.log "watched", watched
            return if not watched?
            scope.watchers = _.map(watched.watchers, (watcherId) -> scope.usersById[watcherId])

    directive = {
        link: link
        templateUrl: "components/watchers/watchers.html"
        #TODO: fix this
        #Si dejo true deja de funcionar el watch
        bindToController: {}
        controller: "Watchers"
        controllerAs: "vm"
        scope: {
            "watched": "=tgWatchers"
            "project": "="
            "usersById": "="
            "requiredPerm": "@"
            "getTitle": "="
        }
    }

    return directive


angular.module("taigaComponents").directive("tgWatchers", ["$rootScope",
    "$tgConfirm", "$tgRepo", "$tgQqueue", "$translate", WatchersDirective])
