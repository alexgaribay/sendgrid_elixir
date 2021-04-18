defmodule SendGrid.Template do

  def new(%{"generation" => "dynamic"} = json, :json) do
    SendGrid.DynamicTemplate.new(json, :json)
  end


  def new(%{"generation" => "legacy"} = json, :json) do
    SendGrid.LegacyTemplate.new(json, :json)
  end

end