class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.json
  def index
    if params[:azione]=="1"
     Job.initialize_jobs( params[:step].to_i,params[:from].to_i, params[:to].to_i)
     redirect_to jobs_path
     return
    elsif params[:azione]=="2"
      Job.gt(con_prodotti: 0).each do |j|
        j.update_attributes({status: "new", eseguiti: 0, con_prodotti:0, con_prezzi: 0})
        j.save
      end
      redirect_to jobs_path
      return
    elsif params[:azione]=="3"
      Job.where(con_prodotti: 0).each do |j|
        j.update_attributes({status: "new", eseguiti: 0, con_prodotti:0, con_prezzi: 0})
        j.save
      end
      redirect_to jobs_path
      return
    elsif params[:azione]=="4"
      Job.where(status: "working").each do |j|
        j.update_attributes({status: "new", eseguiti: 0, con_prodotti:0, con_prezzi: 0})
        j.save
      end
      redirect_to jobs_path
      return
    end

    @jobs = Job.all.sort(:updated_at.desc)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.find(params[:id])
    @job.update_attributes({status: "new", eseguiti: 0, con_prodotti:0, con_prezzi: 0})
    @job.save
    redirect_to jobs_path

  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @job = Job.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.json
  def create
    klass=params[:import].constantize
    import_job=klass.new(params[:from].to_i)
    start_time=Time.new
    j=Job.create(:description=>"import #{klass.to_s}", :start_time=>start_time)

    fork do
      begin
        (params[:from].to_i..params[:to].to_i).each do |i|
          puts "job #{start_time} #{params} - #{i}"
          import_job.get_product(i)
          j["status"]="#{params[:from].to_i}=>#{params[:to].to_i} : #{i}"
          j.save
        end
        j["status"]="#{params[:from].to_i}=>#{params[:to].to_i} : complete"
        j["end_time"]=Time.new
        j.save
      rescue Exception => e
        j["status"]="#{params[:from].to_i}=>#{params[:to].to_i} : #{e.backtrace}"
      end
    end
    redirect_to jobs_path()
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
    @job = Job.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end
end
