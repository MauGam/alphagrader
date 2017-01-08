# frozen_string_literal: true
class TestsController < ApplicationController
  before_action :normalize_params

  load_and_authorize_resource :assignment
  load_and_authorize_resource through: :assignment

  def page_title
    'Tests'
  end

  def new
    cast_test
  end

  def edit
  end

  def update
    if @test.update_attributes(test_params)
      redirect_to [@assignment.course, @assignment], flash: { success: 'Test was successfully updated' }
    else
      render 'new'
    end
  end

  def create
    cast_test!
    if @test.save
      redirect_to [@assignment.course, @assignment], flash: { success: 'Test was successfully created' }
    else
      render 'new'
    end
  end

  def destroy
    @test.destroy
    redirect_to [@assignment.course, @assignment], flash: { success: 'Test was successfully deleted' }
  end

  private

  def type_param
    params[:type] || params.dig(:test, :type)
  end

  def cast_test!
    raise unless type_param
    cast_test
  end

  def cast_test
    return unless type_param
    key = type_param.underscore.to_sym
    test_type = Test::VALID_TEST_TYPES.fetch(key).fetch(:class)
    @test = @test.becomes(test_type)
    @test.type = test_type
  end

  def test_params
    params.require(:test).permit(:name, :public, :description,
                                 :program_input, :expected_program_output)
  end

  def normalize_params
    params[:test] ||= Test::VALID_TEST_TYPES.keys.map do |key|
      params[key]
    end.compact.first
  end
end
