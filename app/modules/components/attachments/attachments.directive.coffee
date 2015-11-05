AttachmentsDirective = () ->
    link = (scope, el, attrs, ctrl) ->

    return {
        scope: {},
        bindToController: {
            attachments: "=",
            onAdd: "&",
            onDelete: "&"
        },
        controller: "Attachments",
        controllerAs: "vm",
        templateUrl: "components/attachments/attachments.html",
        link: link
    }

AttachmentsDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentsSimple", AttachmentsDirective)


bindOnce = @.taiga.bindOnce

AttachmentsLightboxCreateDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        bindOnce scope, 'vm.objId', (value) ->
            ctrl.loadAttachments()

    return {
        scope: {},
        bindToController: {
            type: "@",
            objId: "="
            projectId: "="
        },
        controller: "Attachments2",
        controllerAs: "vm",
        templateUrl: "components/attachments/attachments-full.html",
        link: link
    }

AttachmentsDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentsFull", AttachmentsLightboxCreateDirective)
