class TimeLoggersController < ApplicationController
  unloadable

  def index
    if User.current.nil?
        @user_time_loggers = nil
        @time_loggers = TimeLogger.where(paused: 0)
        @paused_time_loggers = TimeLogger.where(paused: 1)
    else
        @user_time_loggers = TimeLogger.where(user_id: User.current.id)
        @time_loggers = TimeLogger.where('paused = false and user_id != ?', User.current.id)
        @paused_time_loggers = TimeLogger.where('paused = true and user_id != ?', User.current.id)
    end
  end

  def start
    @time_logger = current
    if @time_logger.nil?
      @issue = Issue.find_by_id(params[:issue_id])
      @time_logger = TimeLogger.new(issue_id: @issue.id)
      @action_log = TimeLoggerAction.new({issue_id: @issue.id, action: 'start'})

      if @time_logger.save
        @action_log.save
        apply_status_transition(@issue) unless Setting.plugin_time_logger['status_transitions'].nil?
        render_menu
      else
        flash[:error] = l(:start_time_logger_error)
      end
    else
      flash[:error] = l(:time_logger_already_running_error)
    end
  end

  def resume
    @time_logger = current
    if @time_logger.nil? || !@time_logger.paused
      flash[:error] = l(:no_time_logger_suspended)
      redirect_to :back
    else
      @time_logger.started_on = Time.now
      @time_logger.paused = false
      if @time_logger.save
        @action_log = TimeLoggerAction.new({issue_id: @time_logger.issue_id, action: 'resume'})
        @action_log.save
        render_menu
      else
        flash[:error] = l(:resume_time_logger_error)
      end
    end
  end

  def suspend
    if Setting.plugin_time_logger['show_pause']
        @time_logger = current
        if @time_logger.nil? or @time_logger.paused
            flash[:error] = l(:no_time_logger_running)
            redirect_to :back
        else
            @time_logger.time_spent = @time_logger.hours_spent
            @time_logger.paused = true
            if @time_logger.save
                @action_log = TimeLoggerAction.new({issue_id: @time_logger.issue_id, action: 'pause'})
                @action_log.save
                render_menu
            else
                flash[:error] = l(:suspend_time_logger_error)
            end
        end
    else
        flash[:error] = l(:suspend_time_logger_error)
    end
  end

  def stop
    @time_logger = current
    if @time_logger.nil?
      flash[:error] = l(:no_time_logger_running)
      redirect_to :back
    else
      issue_id = @time_logger.issue_id
      hours = @time_logger.hours_spent.round(2)
      @time_logger.destroy
      @action_log = TimeLoggerAction.new({issue_id: issue_id, action: 'stop'})
      @action_log.save

      redirect_to_new_time_entry = Setting.plugin_time_logger['redirect_to_new_time_entry']

      if redirect_to_new_time_entry
        redirect_to controller: 'timelog',
                    protocol: Setting.protocol,
                    action: 'new',
                    issue_id: issue_id,
                    time_entry: { hours: hours }
      else
        redirect_to controller: 'issues',
                    protocol: Setting.protocol,
                    action: 'edit',
                    id: issue_id,
                    time_entry: { hours: hours }
      end
    end
  end

  def delete
    time_logger = TimeLogger.find_by_id(params[:id])
    if !time_logger.nil?
      time_logger.destroy
      flash[:notice] = l(:time_logger_delete_success)
      respond_to do |format|
        format.html { redirect_to time_loggers_path }
      end
    else
      flash[:error] = l(:time_logger_delete_fail)
      respond_to do |format|
        format.html { redirect_to time_loggers_path }
      end
    end
  end

  def render_menu
    @project = Project.find_by_id(params[:project_id])
    @issue = Issue.find_by_id(params[:issue_id])
    render partial: 'embed_menu'
  end

  protected

  def current
    TimeLogger.find_by_user_id(User.current.id)
  end

  def apply_status_transition(issue)
    new_status_id = Setting.plugin_time_logger['status_transitions'][issue.status_id.to_s]
    new_status = IssueStatus.find_by_id(new_status_id)
    if issue.new_statuses_allowed_to(User.current).include?(new_status)
      journal = @issue.init_journal(User.current, notes = l(:time_logger_label_transition_journal))
      @issue.status_id = new_status_id
      @issue.save
    end
  end
end
