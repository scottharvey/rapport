module Rapport
  class SweepsController < ApplicationController
    def create
      Sweep.call
      redirect_to root_path, notice: "Sweep finished."
    end
  end
end
