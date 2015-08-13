AttachmentDirective = () ->
    link = (scope, el, attrs, ctrl) ->

    return {
        scope: {},
        bindToController: {
            attachment: "=",
            onDelete: "&",
            onUpdate: "&"
        },
        controller: "Attachment",
        controllerAs: "vm",
        templateUrl: "components/attachment/attachment.html",
        link: link
    }

AttachmentDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachment2", AttachmentDirective)
