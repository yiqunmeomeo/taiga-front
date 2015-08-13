AttachmentLinkDirective = ($rootScope, $parse) ->
    link = (scope, el, attrs) ->
        attachment = $parse(attrs.tgAttachmentLink)(scope)

        el.on "click", (event) ->
            if taiga.isImage(attachment.get('name'))
                event.preventDefault()

                scope.$apply ->
                    $rootScope.$broadcast("attachment:preview", attachment)

        scope.$on "$destroy", -> el.off()
    return {
        link: link
    }

AttachmentLinkDirective.$inject = [
    "$rootScope",
    "$parse"
]

angular.module("taigaComponents").directive("tgAttachmentLink", AttachmentLinkDirective)
