RSpec.describe SafeURI do
  it "has a version number" do
    expect(SafeURI::VERSION).not_to be nil
  end

  describe '#open' do
    subject { described_class.open(url) }

    context 'when a pipe character is given' do
      let(:url) { '| ls' }

      it 'raises an exception' do
        expect { subject }.to raise_error(Errno::ENOENT)
      end
    end

    context 'when provided an unknown scheme unsupported by open-uri' do
      let(:url) { 'unknown://foo.bar' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SafeURI::UnsupportedScheme)
      end
    end

    context 'when an existing valid file name is given' do
      let(:url) { 'spec/fixtures/テスト用fixture（日本語）.txt' }

      it 'raises no error' do
        expect { subject }.not_to raise_error
      end

      it 'can read the file' do
        expect(subject.read).to eq "テスト用フィクスチャ\n"
      end
    end
  end

  describe '#parse_url' do
    subject { described_class.parse_url(url) }

    shared_examples 'parse https addresses with proper manner' do
      it 'returns a URI::HTTPS instance' do
        expect(subject).to be_an_instance_of(URI::HTTPS)
      end

      it 'encodes the given uri' do
        expect(subject.to_s).to eq(encoded_uri)
      end
    end

    context 'with only ascii (unresearved) characters' do
      context 'ascii-only uri' do
        let(:url) { 'https://www.google.com' }
        let(:encoded_uri) { 'https://www.google.com/' }
        it_behaves_like 'parse https addresses with proper manner'
      end

      context 'percent-encoded uri' do
        let(:url) { 'https://ja.wikipedia.org/wiki/%E5%8A%92%E5%B2%B3_%E7%82%B9%E3%81%AE%E8%A8%98#%E3%81%82%E3%82%89%E3%81%99%E3%81%98' }
        let(:encoded_uri) { url }
        it_behaves_like 'parse https addresses with proper manner'
      end
    end

    context 'with non-ascii characters' do
      context 'before being percent encoded' do
        let(:url) { 'https://nipponの住所.com/東京都/練馬区/月見台/' }
        let(:encoded_uri) { 'https://xn--nippon-ge4eq27t5v9a.com/%E6%9D%B1%E4%BA%AC%E9%83%BD/%E7%B7%B4%E9%A6%AC%E5%8C%BA/%E6%9C%88%E8%A6%8B%E5%8F%B0/' }
        it_behaves_like 'parse https addresses with proper manner'
      end

      context 'mixed segments with and without percent-encoding' do
        let(:url) { 'https://nipponの住所.com/%E6%9D%B1%E4%BA%AC%E9%83%BD/練馬区/%E6%9C%88%E8%A6%8B%E5%8F%B0/' }
        let(:encoded_uri) { 'https://xn--nippon-ge4eq27t5v9a.com/%E6%9D%B1%E4%BA%AC%E9%83%BD/%E7%B7%B4%E9%A6%AC%E5%8C%BA/%E6%9C%88%E8%A6%8B%E5%8F%B0/' }
        it_behaves_like 'parse https addresses with proper manner'
      end
    end

    context 'with other acceptable protocols' do
      let(:url) { 'ftp://瑞牆山.org/トポ/不動沢/魔天岩' }
      let(:encoded_uri) { 'ftp://xn--rhtx12c6ob.org/%E3%83%88%E3%83%9D/%E4%B8%8D%E5%8B%95%E6%B2%A2/%E9%AD%94%E5%A4%A9%E5%B2%A9' }

      it 'returns a URI::FTP instance' do
        expect(subject).to be_an_instance_of(URI::FTP)
      end

      it 'encodes the given uri' do
        expect(subject.to_s).to eq(encoded_uri)
      end
    end

    context 'when given a uri with unknown scheme' do
      let(:url) { 'unknown://foo.bar' }
      let(:escaped_uri) { url }

      it 'returns a URI::Generic instance' do
        expect(subject).to be_an_instance_of(URI::Generic)
      end

      it 'encodes the given characters' do
        expect(subject.to_s).to eq(escaped_uri)
      end
    end

    context 'when a pipe character is given' do
      let(:url) { '| ls' }
      let(:escaped_uri) { '%7C%20ls' }

      it 'returns a URI::Generic object' do
        expect(subject).to be_an_instance_of(URI::Generic)
      end

      it 'encodes the given characters' do
        expect(subject.to_s).to eq(escaped_uri)
      end
    end
  end
end
