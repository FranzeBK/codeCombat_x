ModalView = require 'views/core/ModalView'
State = require 'models/State'
template = require 'app/templates/courses/courses-not-assigned-modal'

{ STARTER_LICENSE_COURSE_IDS } = require 'core/constants'

module.exports = class CoursesNotAssignedModal extends ModalView
  id: 'courses-not-assigned-modal'
  template: template

  initialize: (options) ->
    @i18nData = _.pick(options, ['selected', 'numStudentsWithoutFullLicenses', 'numFullLicensesAvailable'])
    @state = new State({
      promoteStarterLicenses: false
    })
    if options.courseID in STARTER_LICENSE_COURSE_IDS
      @supermodel.trackRequest(me.getLeadPriority())
        .then(({ priority }) => @state.set({ promoteStarterLicenses:
          me.useStripe() and
          (priority is 'low') and
          (me.get('preferredLanguage') not in ['nl-BE', 'nl-NL']) and
          (me.get('country') not in ['australia', 'taiwan', 'hong-kong', 'netherlands', 'indonesia', 'singapore', 'malaysia']) and
          not me.get('administratedTeachers')?.length
        }))
    @listenTo @state, 'change', @render
