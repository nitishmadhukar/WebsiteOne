class CreateEvent
  def self.with(listener, params, model_klass = Event)
    new(listener, params, model_klass).send(:run)
  end

  private

  attr_reader :listener, :params, :model_klass

  def initialize(listener, params, model_klass)
    @listener = listener
    @params = params
    @model_klass = model_klass
  end

  def run
    create_start_datetime
    handle_repeat_ends_settings
    add_defaults
    model_klass.new(params)
  end

  def create_start_datetime
    event_params = params.require(:event).permit!
    if (params['start_date'].present? && params['start_time'].present?)
      Time.zone = params["start_time_tz"]["time_zone"]
      event_params[:start_datetime] = Time.zone.parse(params["start_date"]+" " + params["start_time"]).utc
    end
    @params = event_params
  end

  def handle_repeat_ends_settings
    @params[:repeat_ends] = (params['repeat_ends_string'] == 'on')
    @params[:repeat_ends_on]= params[:repeat_ends_on].present? ? "#{params[:repeat_ends_on]} UTC" : ""
  end

  def add_defaults
    @params[:start_datetime] = Time.now if params[:start_datetime].blank?
    @params[:duration] = 30.minutes if params[:duration].blank?
    @params[:repeat_ends] = (params[:repeat_ends_string] == 'on') ? true : false
  end
end
