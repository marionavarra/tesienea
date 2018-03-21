class ClassificationsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_classification, only: [:show, :edit, :update, :destroy]

  # GET /classifications
  # GET /classifications.json
  def index
    @classifications = Classification.all
  end

  # GET /classifications/1
  # GET /classifications/1.json
  def show
  end

  # GET /classifications/new
  def new
    @classification = Classification.new
  end

  # GET /classifications/1/edit
  def edit
  end

  # POST /classifications
  # POST /classifications.json
  def create
    file = ["maltempo","manutenzione","guasto","telecomunicazioni","stradale","idrico","elettrico"]
    path = "/home/dimartino/Documenti/mario/codice/tesienea/web/classificatore/"
	@classification = Classification.new(classification_params)
    file_test_output = File.open("public/data/test_output.txt", "w")
    file_dizionario = File.open("public/data/dizionario2.txt", "r")
    
	linee =  file_dizionario.readlines
    doc = @classification.notizia
    out=doc.gsub /^\s*$/m, ''                       # Remove carriage return
    out=out.gsub(/\s\s+/, "\s")  				#remove double space
    body=out.downcase.gsub(/\W+/, ' ')			#remove everything but the words
    out = rimuovi_non_in_dizionario(body,linee) unless body.nil?
    out="text\n" + out.gsub(/\s\s+/, "\s")
    file_test_output.write(out)
    file_test_output.close
    @classification.estratto = out
	th = []
	th2 = []
	t=0
	file.each do |f|
	  th[t]=Thread.new do
	      Thread.current["mycount"] = t
		  t*=1
		  command = "spark-submit --class ClassifierLogReg #{path}public/scala/classifierlogreg_2.11-0.1.0-SNAPSHOT.jar #{f} 2>> #{path}public/data/error > #{path}public/data/#{f}.result.txt"
		  logger.info  command
		  system(command)
	  end
	  th[t]=Thread.new do
	      Thread.current["mycount"] = t
		  t*=1
		  command2 = "spark-submit --class ClassifierPerceptron #{path}public/scala/classifierperceptron_2.11-0.1.0-SNAPSHOT.jar #{f} 2>> #{path}public/data/error2 > #{path}public/data/#{f}2.result.txt"
      	  logger.info  command2
		  system(command2)
	  end	  
	end
	th.each {|t| t.join; print t["mycount"], "/tFinito #{DateTime.now.strftime("%d/%m/%Y %H:%M:%S")}/ " }
	file.each do |f|
      positivo = false
		ris_letto = `cat #{path}public/data/#{f}.result.txt`.split(":")[1].split(".")[0]
		logger.info ris_letto
		if  ris_letto == "1"
		  positivo = true
		  logger.info "Positivo"
		end
		case f 
          when "maltempo"
            @classification.maltempo =  positivo
          when "manutenzione"
            @classification.manutenzione =  positivo
          when "guasto"
            @classification.guasto =  positivo
          when "telecomunicazioni"
             @classification.telecomunicazioni2 =  positivo
          when "stradale"
            @classification.stradale =  positivo
          when "idrico"
            @classification.idrica =  positivo
          when "elettrico"
            @classification.elettrica =  positivo
         end
	end
	file.each do |f|
		positivo = false
		ris_letto = `cat #{path}public/data/#{f}2.result.txt`.split(":")[1].split(".")[0]
		logger.info ris_letto
		if  ris_letto == "1"
		  positivo = true
		  logger.info "Positivo"
		end
		case f 
          when "maltempo"
            @classification.maltempo2 =  positivo
          when "manutenzione"
            @classification.manutenzione2 =  positivo
          when "guasto"
            @classification.guasto2 =  positivo
          when "telecomunicazioni"
             @classification.telecomunicazioni2 =  positivo
          when "stradale"
            @classification.stradale2 =  positivo
          when "idrico"
            @classification.idrica2 =  positivo
          when "elettrico"
            @classification.elettrica2 =  positivo
         end
    end
  respond_to do |format|
      if @classification.save
        format.html { redirect_to @classification, notice: 'Classification was successfully created.' }
        format.json { render :show, status: :created, location: @classification }
      else
        format.html { render :new }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /classifications/1
  # PATCH/PUT /classifications/1.json
  def update
    respond_to do |format|
      if @classification.update(classification_params)
        format.html { redirect_to @classification, notice: 'Classification was successfully updated.' }
        format.json { render :show, status: :ok, location: @classification }
      else
        format.html { render :edit }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /classifications/1
  # DELETE /classifications/1.json
  def destroy
    @classification.destroy
    respond_to do |format|
      format.html { redirect_to classifications_url, notice: 'Classification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_classification
      @classification = Classification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def classification_params
      params.require(:classification).permit(:notizia, :maltempo, :manutenzione, :guasto, :idrica, :stradale, :telecomunicazioni, :elettrica)
    end
  def rimuovi_non_in_dizionario_old text,dizionario
    text.split.each do |p_text|
      trovata = false
      dizionario.each do |linea|
        p_diz = linea.split[0]
        if p_text == p_diz
          trovata=true
          break
        end 
      end
      unless trovata
        text = text.gsub(/\b#{p_text}\b/, '')
      end 
    end
    text
  end
  def rimuovi_non_in_dizionario text,dizionario
  text.split.each do |p_text|
    trovata = false
	lemma = ""
    dizionario.each do |linea|
      p_diz = linea.split[0]
	  lemma = linea.split[1]
      if p_text == p_diz
        trovata=true
		text = text.gsub(/\b#{p_text}\b/, lemma)#	unless text.nil?  
        break
      end 
    end
    unless trovata
      text = text.gsub(/\b#{p_text}\b/, '')	  
    end 
  end
  text
end
end
