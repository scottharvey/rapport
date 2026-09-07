module Rapport
  class CompaniesController < ApplicationController
    before_action :set_company, only: %i[show edit update destroy]

    def index
      @pagy, @companies = pagy(Company.alphabetical.includes(:contacts))
    end

    def show
      @contacts = @company.contacts.includes(:email_addresses).recent_first
      @account = @company.account
    end

    def new
      @company = Company.new
    end

    def create
      @company = Company.new(company_params)
      if @company.save
        redirect_to @company, notice: "Company created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @company.update(company_params)
        redirect_to @company, notice: "Company updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @company.destroy!
      redirect_to companies_path, notice: "Company deleted."
    end

    private

    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :domain)
    end
  end
end
