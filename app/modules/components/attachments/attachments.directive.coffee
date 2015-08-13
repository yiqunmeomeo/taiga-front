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

AttachmentsLightboxCreateDirective = () ->
    link = (scope, el, attrs, ctrl) ->

        scope.$watch 'vm.attachmentsAll', (attachments) ->
            ctrl.generate() if attachments

    return {
        scope: {},
        bindToController: {
            attachmentsAll: "=attachments"
        },
        controller: "Attachments",
        controllerAs: "vm",
        templateUrl: "components/attachments/attachments-full.html",
        link: link
    }

AttachmentsDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentsFull", AttachmentsLightboxCreateDirective)
