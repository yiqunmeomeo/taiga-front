taiga = @.taiga
mixOf = @.taiga.mixOf

class Watchers extends mixOf(taiga.Controller)
    @.$inject = [
        "$rootScope"
        "$tgConfirm"
        "$tgRepo"
        "$tgQqueue"
        "$translate"
    ]

    constructor: (@rootscope, @confirm, @repo, @qqueue, @translate) ->

    isEditable: (project, requiredPerm) ->
        return project?.my_permissions?.indexOf(requiredPerm) != -1

    saveWatchers: @qqueue.bindAdd (watched, watchers) ->
        watched.watchers = watchers
        promise = @repo.save(watched)
        promise.then ->
            @confirm.notify("success")
            @.watchers = _.map(watchers, (watcherId) -> @.usersById[watcherId])
            @rootscope.$broadcast("history:reload")

        promise.then null, ->
            watched.revert()

    deleteWatcher: (watched, watcher, usersById) ->
        title = @translate.instant("COMMON.WATCHERS.DELETE")
        message = @.usersById[watcher.id].full_name_display

        @confirm.askOnDelete(title, message)
        .then @qqueue.bindAdd  (finish) ->
            @qqueue.add ->
                finish()
                watchers = _.clone(watched.watchers, false)
                watchers = _.pull(watchers, watcher.id)
                @.watched.watchers = watchers
                @.watchers = _.map(watchers, (watcherId) -> usersById[watcherId])
                return @repo.save(watched)

        .then ->
            @confirm.notify("success")
            @rootscope.$broadcast("history:reload")

        .then null, ->
            watcher.revert()
            @confirm.notify("error")

    getTitle: (project, requiredPerm, watchers) ->
        if @.isEditable(project, requiredPerm) and watchers?.length == 0
            return @translate.instant("COMMON.WATCHERS.ADD")
        else
            return @translate.instant("COMMON.WATCHERS.TITLE")

    addWatcher: (watched) ->
        @rootscope.$broadcast("watcher:add", watched)

angular.module("taigaComponents").controller("Watchers", Watchers)
