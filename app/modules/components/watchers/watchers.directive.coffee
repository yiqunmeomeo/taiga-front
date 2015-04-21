WatchersDirective = ($rootscope, confirm, repo, qqueue, $translate) ->
    # You have to include a div with the tg-lb-watchers directive in the page
    # where use this directive

    link = (scope, el, attrs) ->
        scope.isEditable = ->
            return scope.project?.my_permissions?.indexOf(scope.requiredPerm) != -1

        saveWatchers = qqueue.bindAdd (watchers) =>
            scope.watched.watchers = watchers
            promise = repo.save(scope.watched)
            promise.then ->
                confirm.notify("success")
                scope.watchers = _.map(watchers, (watcherId) -> scope.usersById[watcherId])
                $rootscope.$broadcast("history:reload")

            promise.then null, ->
                scope.watched.revert()

        scope.deleteWatcher = (watcher) =>
            return if not scope.isEditable()
            title = $translate.instant("COMMON.WATCHERS.DELETE")
            message = scope.usersById[watcher.id].full_name_display

            confirm.askOnDelete(title, message)
            .then qqueue.bindAdd  (finish) =>
                qqueue.add ->
                    finish()
                    watchers = _.clone(scope.watched.watchers, false)
                    watchers = _.pull(watchers, watcher.id)
                    scope.watched.watchers = watchers
                    scope.watchers = _.map(watchers, (watcherId) -> scope.usersById[watcherId])
                    return repo.save(scope.watched)

            .then ->
                confirm.notify("success")
                $rootscope.$broadcast("history:reload")

            .then null, ->
                watcher.revert()
                confirm.notify("error")

        scope.getTitle = ->
            if scope.isEditable() and scope.watchers?.length == 0
                return $translate.instant("COMMON.WATCHERS.ADD")
            else
                return $translate.instant("COMMON.WATCHERS.TITLE")

        scope.addWatcher = ->
            return if not scope.isEditable()
            $rootscope.$broadcast("watcher:add", scope.watched)

        scope.$on "watcher:added", (ctx, watcherId) ->
            watchers = _.clone(scope.watched.watchers, false)
            watchers.push(watcherId)
            watchers = _.uniq(watchers)
            saveWatchers(watchers)

        scope.$watch "watched", (watched) ->
            return if not watched?
            scope.watchers = _.map(watched.watchers, (watcherId) -> scope.usersById[watcherId])

    directive = {
        link: link
        templateUrl: "components/watchers/watchers.html"
        bindToController: true
        controller: "Watchers"
        scope: {
            "watched": "=tgWatchers"
            "project": "="
            "usersById": "="
            "requiredPerm": "@"
        }
    }

    return directive


angular.module("taigaComponents").directive("tgWatchers", ["$rootScope",
    "$tgConfirm", "$tgRepo", "$tgQqueue", "$translate", WatchersDirective])
