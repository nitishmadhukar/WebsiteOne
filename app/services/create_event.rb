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
    handle_repeat_ends_settings
    create_start_datetime
    @params = params.require(:event).permit!
    add_defaults
    model_klass.new(params)
  end

  def create_start_datetime
    if (params['start_date'].present? && params['start_time'].present?)
      Time.zone = params["start_time_tz"]["time_zone"]
      @params[:event][:start_datetime] = Time.zone.parse(params["start_date"]+" " + params["start_time"]).utc
    end
  end

  def handle_repeat_ends_settings
    @params[:event][:repeat_ends] = (params[:event]['repeat_ends_string'] == 'on')
    @params[:event][:repeat_ends_on]= params[:repeat_ends_on].present? ? "#{params[:repeat_ends_on]} UTC" : ""
  end

  def add_defaults
    @params[:start_datetime] = Time.now if params[:start_datetime].blank?
    @params[:duration] = 30.minutes if params[:duration].blank?
    @params[:repeat_ends] = (params[:repeat_ends_string] == 'on') ? true : false
  end
end
