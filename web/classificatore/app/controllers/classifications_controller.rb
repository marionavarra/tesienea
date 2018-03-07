class ClassificationsController < ApplicationController
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
    @classification = Classification.new(classification_params)
    file_test_output = File.open("public/data/test_output.txt", "w")
    file_dizionario = File.open("public/data/dizionario.txt", "r")
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
    file.each do |f|
      command = "spark-submit --class ClassifierLogReg public/scala/classifierlogreg_2.11-0.1.0-SNAPSHOT.jar #{f} 2>/dev/null > public/data/#{f}.result.txt"
      if system(command)
	 case f 
          when "maltempo"
            @classification.maltempo =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
          when "manutenzione"
            @classification.manutenzione =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
          when "guasto"
            @classification.guasto =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
          when "telecomunicazioni"
            @classification.telecomunicazioni =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
          when "stradale"
            @classification.stradale =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
          when "idrico"
            @classification.idrica =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
          when "elettrico"
            @classification.elettrica =  `cat public/data/#{f}.result.txt`.split(":")[1].to_i
         end
      end 
      command2 = "spark-submit --class ClassifierPerceptron public/scala/classifierperceptron_2.11-0.1.0-SNAPSHOT.jar #{f} 2>/dev/null > public/data/#{f}.result.txt"
       if system(command2)
	 case f 
          when "maltempo"
            @classification.maltempo2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
          when "manutenzione"
            @classification.manutenzione2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
          when "guasto"
            @classification.guasto2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
          when "telecomunicazioni"
            @classification.telecomunicazioni2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
          when "stradale"
            @classification.stradale2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
          when "idrico"
            @classification.idrica2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
          when "elettrico"
            @classification.elettrica2 =  `cat public/data/#{f}2.result.txt`.split(":")[1].to_i
         end
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
  def rimuovi_non_in_dizionario text,dizionario
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
end
