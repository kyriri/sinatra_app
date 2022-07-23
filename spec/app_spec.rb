RSpec.describe App, type: :request do
  let(:app) { App.new }

  context 'receives GET "/"' do
    let(:response) { get '/' }

    it 'and returns a response' do
      expect(response).to be
    end
  end
end