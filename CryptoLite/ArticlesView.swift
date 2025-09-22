//
//  ArticlesView.swift
//  CryptoLite
//
//  Created by AI Assistant on 22.09.2025.
//

import SwiftUI

struct ArticlesView: View {
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    private let headerPlaceholderHeight: CGFloat = 120
    private let headerTopPadding: CGFloat = 24
    private let spacingAfterHeader: CGFloat = 16
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Подложка: прозрачный блок высоты хедера + белый фон до низа
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: headerPlaceholderHeight + headerTopPadding + spacingAfterHeader)
                    Color.white
                        .ignoresSafeArea(edges: .bottom)
                }
                
                // Контент панели: скругления только сверху. Прокрутка только для статей
                VStack(spacing: 16) {
                    Spacer(minLength: 0)
                        .frame(height: headerPlaceholderHeight)
                        .padding(.top, headerTopPadding)
                    
                    VStack(spacing: 16) {
                        sectionHeader
                        
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                                ForEach(sampleArticles) { article in
                                    NavigationLink {
                                        ArticleDetailView(article: article)
                                    } label: {
                                        ArticleCardView(article: article)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    ))
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .padding(.top, 8)
                .background(
                    Image("criptoLite_bg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
            }
        }
    }
        
    private var sectionHeader: some View {
            HStack(alignment: .firstTextBaseline) {
                Text("Recommended articles")
                    .font(.title2).bold()
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button("Read all") {}
                    .font(.subheadline)
            }
    }
    
    private struct Article: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let gradient: [Color]
        let body: String?
    }
    
    private struct ArticleDetailView: View {
        let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite: Bool = false
    @StateObject private var featuredStore = FeaturedArticlesStore.shared
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.blue)
                    
                    Text(article.subtitle)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    if let body = article.body, !body.isEmpty {
                        Text(body)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(16)
            }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isFavorite.toggle()
                    featuredStore.toggleFavorite(id: article.title.slugifiedId, title: article.title, subtitle: article.subtitle)
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(.gray)
                }
            }
        }
        }
    }
    
    private struct ArticleCardView: View {
        let article: Article
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                // Базовый фон — градиент
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: article.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                
                // Картинка отключена — используем дефолтный фон
                
                // Overlay noise/illustration placeholder
                Image(systemName: "hexagon")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.12)
                    .frame(width: 120)
                    .foregroundStyle(.black)
                    .offset(x: 50, y: -30)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                        .lineLimit(2)
                    
                    Text(article.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(3)
                    
                    HStack(spacing: 6) {
                        Text("Read all")
                            .font(.footnote).bold()
                            .foregroundStyle(.white)
                        Image(systemName: "arrow.right")
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 2)
                }
                .padding(12)
            }
            .frame(height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.2))
            )
        }
    }
    
    private let sampleArticles: [Article] = [
        Article(
            title: "Weekly Top Stories - 9/19/25",
            subtitle: "In the newsletter this week, Zack Pokorny contextualizes the Ink rollup’s move to decentralize itself; Thad Pinakiewicz unpacks Tether’s new, U.S.-only stablecoin; and Christopher Rosa explains Google’s new standard for AI agent-initiated payments.",
            gradient: [Color.green.opacity(0.9), Color.teal.opacity(0.9)],
            body: """
Kraken to Test 'Based' Rollup Architecture

Ink, the Kraken exchange’s OP Stack-based optimistic rollup (a type of layer-2 blockchain on Ethereum), announced plans to test a so-called based sequencing mechanism. The move comes in the wake of discourse and uncertainty around the regulatory viability of centrally sequenced rollups to handle tokenized securities and other real-world asset (RWA) activities. In a based rollup, the sequencing of transactions is handled by a subset of the layer-1 (L1) chain's block proposers. This differs from single-sequenced rollups (e.g., Arbitrum, Base, and OP Mainnet), which have a single, central entity that orders transactions. Ink’s announcement is significant because centrally sequenced rollups have been the go-to solution for Ethereum scalability, yet they have faced criticism over the years. Recently, Alex Thorn of Galaxy Research has criticized optimistic rollups for their “lack of alignment” with ETH holders, and he has argued that they must either decentralize or be regulated to be fit for tokenized securities. Despite years of roadmaps calling for it and some of these criticisms, few established L2s have taken steps to decentralize sequencers. There has been little incentive for them to do so because decentralization would mean relinquishing direct control over the rollup, putting user experience (UX) at risk, and threatening the economic moat of the sequencing design.

OUR TAKE:
Ethereum rollups have long faced criticism for being "parasitic" (siphoning value capture away from the L1) and "lacking alignment" (operating mostly independently of the L1). Now, with regulatory conversations homing in on sequencer decentralization, rollups may face a new and powerful vector of decentralization pressure. Based sequencing, though still in its early stages of development and implementation, increasingly looks like the most viable long-term option for rollups that decentralize, whether voluntarily or under external pressure.

Rollups are presented with four options for decentralizing their sequencers that are reasonably achievable today:

Shared sequencing networks: These rely on an external and independent validator set and consensus protocol to sequence transactions for multiple rollups. The pros of this approach include immediate decentralization and cross-rollup interoperability among participating rollups. Cons include the complexity and overhead of adding a new consensus protocol and the possibility of a fractured ecosystem, made up of multiple, non-interoperable shared sequencing networks, each with its own independent validator set. This moves the fragmentation problem from individual rollups to the network layer. Additionally, the rollup only becomes as decentralized as the sequencing network it relies on.

Rotating/committee-centric sequencing: The rollup forms its own decentralized sequencer set, either through rotating leaders or a Byzantine Fault Tolerance (BFT) committee, typically secured with proof-of-stake and a staking token. Pros include decentralizing control of the rollup beyond a single operator; keeping economics internal to the rollup; and allowing a choice between a lightweight leader-rotation scheme that simply enforces existing sequencing rules or a full BFT consensus protocol where a committee reaches agreement on ordering. Cons include the possibility of weaker guarantees of liveness or censorship resistance if only a leader-rotation scheme is implemented; the additional complexity, latency, and governance overhead that come with adding another consensus layer if a full BFT committee is implemented; and, in some cases, the need for a staking token (which can be difficult to spin up).

Dual/federated sequencing: Multiple trusted entities (e.g., exchanges and infrastructure providers) run sequencers together; a threshold number of them (e.g., two of three signatures, or three of five) must agree for a block to be accepted. Pros include easier bootstrapping and fewer points of failure. Cons include a permissioned and cartel-like structure with possibly limited censorship resistance and weaker liveness guarantees.

Based sequencing: In its truest form, a subset of L1 proposers is recruited to sequence rollup transactions. In practice, they delegate to gateways (preconfirmers), which handle transaction ordering and user experience (UX), while only L1 proposers finalize rollup activity on Ethereum. The pros include inheriting all qualities of the L1 (decentralization, censorship resistance, and liveness), providing native interoperability with Ethereum and other based rollups, aligning rollup economics more closely with the L1’s, and requiring no new consensus protocols. The cons include a UX bounded by L1 performance (unless preconfirmation infrastructure matures), and the fact that the implementation of true based sequencing is still in its infancy.

Based sequencing stands out as the better option because it directly adopts the decentralization of Ethereum’s validator set, avoiding the need to create or depend on a parallel network of sequencers. It provides native interoperability not only with the Ethereum L1 but also with other rollups that adopt the same model, whereas shared sequencing networks limit interoperability to rollups within their own system. By keeping Ethereum proposers as the sequencing layer, based rollups mitigate the “too many cooks” problem and sidestep the need for novel and unproven shared sequencing networks or the complexity of stacking additional consensus protocols. It also inherits Ethereum’s liveness guarantees and censorship resistance, ensuring that as long as Ethereum continues to produce blocks, the rollup can continue to operate, and transactions cannot be indefinitely suppressed. Crucially, based sequencing still allows rollup operators to define how fees and maximum extractable value (MEV) are distributed across gateways, validators, and the rollup treasury. This optionality gives them some degree of control over economic design while aligning incentives with Ethereum validators through blob fees and inclusion revenue. Combined with the ability for gateways to provide fast and robust preconfirmations for a smoother user experience, based sequencing can offer a cleaner, simpler, and more Ethereum-aligned path to decentralization than the alternatives. Based, indeed.

While based sequencing may provide a strong path forward, it also directly challenges the incumbent incentive model: single-sequencer rollups are money-making machines because they internalize all fees and MEV at high margins to a single entity. Any decentralization of the sequencer, whether through shared sequencing, rotating committees, federations, or going based, necessarily fragments that revenue stream and adds costs. This economic reality is a contributing factor to the hesitancy of rollups to decentralize, even in the face of mounting social and now (possibly) regulatory pressure. The tradeoffs in cost vectors between centrally sequenced rollups and based rollups are shown below. Note: it is still unclear what share of based rollups’ revenue they would have to pay to gateways and possibly L1 validators to properly incentivize operation (this is true of all moves to decentralize the sequencer). Presumably, it will vary from rollup to rollup.
"""
        ),
        Article(
            title: "Cheat Sheet: The President’s Working Group on Digital Asset Markets Report",
            subtitle: "For readers who were on summer vacation when this landmark document dropped (or just could never make the time to read the whole thing), Galaxy Research presents our summary of the key points.",
            gradient: [Color.orange.opacity(0.95), Color.red.opacity(0.9)],
            body: """
The working group was formed in response to an executive order by President Trump, his first such order focused on cryptocurrency, signed just days after his inauguration in January. The PWG is chaired by the president’s special advisor for AI and crypto, David Sacks, and composed of top agency leads and administration officials.

In the executive order, the President tasked the PWG with completing an assessment of government crypto policies and publishing a report of regulatory and legislative proposals comprising a federal framework for crypto policy. The President ordered the PWG to consider policy recommendations for market structure, oversight, consumer protection, and risk management. Additionally, the White House directed the working group to propose criteria for establishing and maintaining a national digital asset stockpile (which would eventually be split into two stashes: a Strategic Bitcoin Reserve, and a stockpile of other digital assets).

The resulting report is split into two main parts. The first part, which encompasses a large portion of the report, is dedicated to reviewing market activities and trends, regulatory and legislative developments, major players in the space, types of products and services, and risks posed by the digital asset ecosystem. The second part is a set of recommendations to inform policy decision making across a range of areas, including market structure, banking, stablecoins and payments, illicit finance, and taxation.

For the most part, the report calls for new legislation and regulations to suit crypto’s distinctive attributes instead of forcing a square peg into a round hole by applying old rules. Throughout the report, the PWG seeks to promote federal policies that encourage the responsible growth and use of digital assets and blockchain technology. The overarching goals of the report are to promote the use of open public blockchain networks; protect the sovereignty of the U.S. dollar by allowing dollar-backed stablecoins to flourish; support fair and open access to banking services for crypto businesses that financial institutions have often shunned; provide regulatory clarity and well-defined jurisdictional boundaries in a technology-neutral manner; and prohibit the establishment of a U.S. central bank digital currency (CBDC).

Overall, the PWG report supports policies that include establishing clear market structure, preventing further debanking of the crypto industry, and tailoring BSA/AML requirements to crypto, while promoting joint SEC/CFTC rulemakings and safe harbors. It also emphasizes exemptions for DeFi developers and clarity on the jurisdictional split between the SEC and CFTC.
"""
        ),
        Article(
            title: "Decentralized AI Training: Architectures, Opportunities, and Challenges",
            subtitle: "Decentralized training has gone from theory to reality. Projects including Nous Research, Prime Intellect, Pluralis, Templar, and Gensyn are running real training at global scale.",
            gradient: [Color.purple.opacity(0.95), Color.indigo.opacity(0.9)],
            body: """
Introduction
Last year, Galaxy Research published its first piece on the intersection of crypto and AI... This first piece focuses on decentralized training, highlighting projects working to enable permissionless training of foundation models on a global scale. Their motivation is twofold: tapping unused GPUs globally for training and creating open alternatives to centralized labs.

For the crypto space, enabling decentralized training and post-training of foundational models is a critical step toward building a fully onchain AI stack. GPU marketplaces can plug into models to provide needed hardware for training and inference, zkML providers can verify outputs, and AI agents can compose higher-order applications.

Model Training Basics covers transformers, forward/backward passes, loss, optimizers, and repeats; post-training explores SFT and RL, with RL particularly well-suited to decentralized settings due to asynchrony and parallelization. Inference uses fixed weights and is less computationally demanding but still heavy due to model size.

Training Overhead: Costs are dominated by GPUs and specialized infra (NVLink, InfiniBand). Leading labs spend from hundreds of millions to billions; GPT-4 training exceeded $100M. Decentralized approaches must prove practical advantages over centralized counterparts while managing orchestration and reliability at scale.
"""
        ),
        Article(
            title: "Weekly Top Stories - 9/12/25",
            subtitle: "In this week's newsletter, Jack Immanuel tracks the market structure bill’s progress in the Senate; Lucas Tcheyan unpacks the outcome of the Hyperliquid vote; and Chris Rosa delivers the tl;dr on the aforementioned NPM exploit.",
            gradient: [Color.gray.opacity(0.9), Color.black.opacity(0.8)],
            body: """
Stablecoin Heavyweights Fight for USDH; Hyperliquid Wins

Hyperliquid, the leading decentralized exchange for perpetual futures and a layer-1 blockchain, is holding its first major governance vote to determine which issuer gets the USDH ticker. Usually tickers are auctioned for HYPE and burned; USDH is different due to its strategic importance. Allocation will be determined via validator vote for a Hyperliquid-aligned, compliant stablecoin. Proposals were submitted by Paxos, Sky, Frax, Agora, Curve, BitGo, OpenEden, Ethena, and newcomers like Native Markets. At the time of writing, 17/19 validators had declared intentions. The vote is set for Sept. 14.

OUR TAKE: The winner gets the right to issue under USDH—a powerful alignment signal, not automatic dominance. Infrastructure remains tied to USDC; criteria for becoming a spot quote asset include staking 200k HYPE and liquidity requirements. Multiple teams plan to launch regardless. Issuers increasingly pay for distribution, pledging most reserve yield back to Hyperliquid. Compliance trade-offs loom. Whatever the outcome, Hyperliquid is the real winner as issuers court its distribution. – Lucas Tcheyan
"""
        ),
        Article(
            title: "A Near-Miss: How the NPM Breach Almost Wreaked Havoc for Crypto Users",
            subtitle: "The node package manager (NPM) account for a reputable software developer who goes by the pseudonym qix was compromised Monday, sending shockwaves through the Javascript community and the web at large, not least of all cryptocurrency users",
            gradient: [Color.blue.opacity(0.9), Color.cyan.opacity(0.8)],
            body: """
A fake two-factor email let attackers publish malicious NPM releases to popular JavaScript libraries maintained by qix. Malicious versions briefly propagated to widely used packages. Impact was limited (~17 txs, ~$1k) thanks to quick remediation and conservative release processes, but the pathway was serious.

OUR TAKE: This was a close call underscoring software supply chain risk across Web3. Pin versions and commit lockfiles; fail CI on vulnerable diffs; restrict publish rights; and monitor builds. Users should avoid blind signing and verify recipient addresses. The incident shows how a single trusted account can become a single point of failure and why disciplined release practices matter.
"""
        ),
        Article(
            title: "Stablecoin Giants Vie for USDH Ticker — Hyperliquid Wins No Matter What",
            subtitle: "On Sept. 5, Hyperliquid, the top decentralized exchange for onchain perpetual futures, announced a governance vote to award the long-reserved USDH ticker to a “Hyperliquid-first, Hyperliquid-aligned, and compliant USD stablecoin.” This is a break from tradition. Ticker rights on Hyperliquid are usually sold every 31 hours in Dutch auctions, with winning bids burning HYPE, the network’s native token. At their peak, those auctions reached as high as $1 million worth of HYPE, settling today closer to $20,000 to $40,000.",
            gradient: [Color.mint.opacity(0.9), Color.teal.opacity(0.8)],
            body: """
USDH, however, is different. With $5.5 billion of USDC balances already powering Hyperliquid and more than $200M in annual yield flowing externally to that stablecoin’s issuer, Circle, the USDH ticker represents a chance to recapture that value for the Hyperliquid network. The winner of the vote won’t automatically replace USDC as the dominant quote currency, but it will gain one of the most coveted forms of digital real estate on the network: the USDH ticker.

The announcement has sparked intense competition among stablecoin issuers, with proposals from Ethena, Sky, Paxos, Agora, Frax Finance, Bastion, OpenEden, and newcomers like Native Markets. It’s Hyperliquid’s first major governance vote outside de‑listings—a test of decentralized decision‑making.

Voting Process and Timeline: Proposals were due Sept. 10 (10:00 UTC), validators had 24h to declare intentions, staked HYPE can be redelegated, and the final vote occurs Sept. 14 (10:00–11:00 UTC). Quorum requires ≥2/3 of total stake. Foundation‑aligned validators (~54%) will abstain until independent quorum is met; combined with Kinetiq abstention, ~63% of HYPE stake won’t participate directly, leaving independent validators to decide. The tight timeline has raised concerns but remains unchanged.

Stablecoin Landscape: USDC dominates Hyperliquid (≈$5.5B; ≈95% share) via a pooled Arbitrum contract rather than native issuance. This bridged setup poses dependency and security risks and routes ≈$220M/year off‑network (including Coinbase’s share). A natively issued USDH could improve security and redirect yield to Hyperliquid.

What Rights Does USDH Confer? The winner gains the right to issue under the USDH ticker and symbolic alignment with Hyperliquid—not control over rails nor automatic market dominance. USDC pairs won’t forcibly migrate, and competitors can still launch. Adoption must be earned via liquidity, integrations, and execution.

Meet the Contenders (highlights):
- Native Markets: Hyper‑native team; on‑chain infra already tested; cash/T‑bills backing with BlackRock/Superstate via Bridge; 50% yield to Assistance Fund, 50% growth.
- Paxos: Institutional scale (BUSD/PYUSD); reserves in bankruptcy‑remote accounts; tiered yield allocation with PayPal incentives; broad integrations.
- Ethena: USDTb/USDe‑backed path; ≥95% yield to ecosystem (potentially 90% post‑KPI); hUSDe and HIP‑3 integrations.
- Agora: White‑label infra with VanEck/State Street; 100% net yield to ecosystem; $10M liquidity seeding.
- Sky: USDS via PSM and sUSDS yield; $25M to seed Hyperliquid DeFi; modular path toward GENIUS alignment.
- Frax: Native issuance via regulated bank; 100% Treasury yield to Hyperliquid; FraxNet for mint/redeem and interoperability.

Bottom line: The ticker signals alignment, not dominance. Regardless of who wins, Hyperliquid benefits as issuers compete to serve its users and direct yield back to the network.
"""
        ),
        Article(
            title: "The State of Onchain Yield: From Stablecoins to DeFi and Beyond",
            subtitle: "Read every headline yield number through two lenses: what you earn for the risk, and what remains after the work involved.",
            gradient: [Color.brown.opacity(0.9), Color.orange.opacity(0.8)],
            body: """
Key Information
Galaxy has partnered with Superstate to allow for tokenization of its Class A Common Stock on the Solana blockchain.

Superstate is Galaxy’s digital transfer agent for the tokenized shares.

Onchain shares of GLXY are actual SEC-registered Galaxy Digital Class A Common Stock that confer all the same legal and economic rights as our traditionally formatted shares.

Those who onboard with Superstate can hold (in self-custody), send and receive onchain shares of GLXY.

Galaxy has not yet enabled AMM-based trading of its onchain shares, though it is possible to transfer GLXY bilaterally between allowlisted entities.

Galaxy shares’ Contract Address on Solana: 2HehXG149TXuVptQhbiWAWDjbbuCsXSAtLTB5wc2aajK

Any tokens from other smart contract addresses that claim to be onchain shares of GLXY stock, or true issuances from Galaxy Digital, are fraudulent.

Galaxy Research created this Dune dashboard to track supply of onchain GLXY: https://dune.com/glxyresearch_team/glxy-class-a-common-stock-token

Introduction
Today, Galaxy announced the tokenization of GLXY Class A Common Stock – the first time in history that a Nasdaq-listed U.S. equity security has been tokenized on a public blockchain.

Galaxy has enabled existing shareholders of its SEC-registered Class A common equity to move their shares from traditional format into onchain versions on the Solana blockchain. By creating a “bridge” between traditional markets and onchain markets, Galaxy has enabled its shareholders to represent their GLXY holdings in tokenized format. When you own these tokenized shares of Galaxy, your tokens are real shares in the company. These are not “wrappers”; they are actual onchain shares. They confer all the same financial and legal rights as our existing public shares, because they are our existing public shares. This is the first time in history that shares of a publicly listed U.S. equity are available on a major public blockchain.

We accomplished this with help from our friends at Superstate, an SEC-registered transfer agent and a leading provider of tokenization services and onchain operations. (Note, Galaxy Ventures is an investor in Superstate).

Persons who complete onboarding with Superstate can hold their shares (in self-custody) and transfer them to addresses on the allowlist. As such, although AMM trading has not yet been enabled, it is possible to transfer GLXY bilaterally between allowlisted entities.

This is just the first step in what we expect will become a capital markets revolution. The Chairman of the SEC has stated that the regulator will “create rational and workable rules of the road” for decentralized systems, including AMMs, within the securities markets. Superstate and Galaxy are both actively engaged with the SEC to help define a model for compliant AMM trading of public equities and we are confident that clear rules will soon emerge.

Galaxy has a demonstrated history of being on the forefront of innovation in finance. We remain committed to continuing to work with key regulators and stakeholders in the industry to advance Galaxy’s long-standing, core mission: building a faster, more efficient, more inclusive, and safer method of value transfer, storage, and creation for the global economy—and tokenized equities are that next step.

How Did We Get Here? Tokenization's History
Humans love to interact directly, bilaterally, peer-to-peer. Direct relationships are our preferred, natural state. But as organizations, systems, and markets scale, these direct connections tend to break down and have often given way to centralized governments, institutions, intermediaries, and organizations. Across history, the story has been the same in most forms of human organization, from local to national politics, production and supply chains, money and markets. Centralization breeds efficiency at the expense of autonomy. And the history of U.S. capital markets has been no exception.

In the late 1960s, U.S. capital markets were booming and market infrastructure couldn’t keep up, leading to the creation of the centralized stock clearing and settlement system we have today. SEC Chairman Paul Atkins described one of the most infamous examples of this breakdown and resulting centralization in his seminal July 31, 2025 speech announcing the Commission’s Project Crypto.

Securities were lost or stolen. Fails ballooned. And many thinly capitalized broker-dealers were caught by the whiplash of scuttled transactions. In desperation, trading hours were reduced and exchanges eventually closed on Wednesdays to allow firms to process the mountains of certificates.

The breakdown over an antiquated system was described by the SEC chairman at the time as “the most prolonged and severe crisis in the securities industry in 40 years... Firms failed. Investor confidence plummeted.” And very much to its credit, the SEC was proactive in remedying the so-called “Paperwork Crisis.” The agency helped market participants to develop the Depository Trust and Clearing Corporation, which would transform how securities were held and traded. Instead of shuffling paper certificates from customer to broker, broker to broker, and broker to customer, title to shares could now be transferred through computerized ledger entries. The certificates themselves were immobilized, stored securely in vaults, as ownership moved electronically, laying the foundation for the modern clearing and settlement system that has continued to this day.

— SEC Chairman Paul Atkins, Jul. 31, 2025

During the booming economy of the 1960s, the direct settlement process relied upon by Wall Street broke down in the face of soaring volumes. In response to this “Paperwork Crisis,” U.S. capital markets abandoned the peer-to-peer settlement process and opted to create centralized intermediation (which would eventually be called the Depository Trust & Clearing Corporation, “DTCC”). This centralized settlement process served us well, allowing U.S. capital markets to grow dramatically over the decades. Had there been a method to avoid the complications of the “Paperwork Crisis” while still maintaining a peer-to-peer process, it’s possible that would have been the preferred solution. In the 1960s, there was no way to scale the growing settlement and recordkeeping needs of Wall Street without the use of a centralized intermediary. But that is no longer the case.

For more than a decade, technologists and financial professionals alike have recognized the transparency and efficiency blockchains provide to the ownership and transfer of assets. The DTCC itself saw the market benefits of and potential for disruption by decentralized, public blockchains as early as 2016, when it published an important whitepaper titled “Embracing Disruption: Tapping the Potential of Distributed Ledgers to Improve the Post-Trade Landscape.”

Over the years, dozens of companies have worked to tokenize real-world assets, including real estate, commodities, physical collectibles, and artwork, mostly with limited adoption. In some cases, headwinds for this class of tokenization attempts have been regulatory, but in most instances the market has failed to bridge the gap between the physical nature of the assets and the intangible nature of the blockchain, with tokenized gold being a notable exception. This is effectively a technological impediment.

In contrast, tokenization efforts in which the underlying assets are intangible or even digital-first have seen much wider adoption. Stablecoins are a breakout hit with wide product market fit, and they are a form of tokenization. Today, they have shown three clear uses that continue to see strong growth: cross-border payments, overseas dollar access in emerging economies, and as a trading pair for bitcoin, ether, and other digital assets. Some categories of tokenization beyond stablecoins have also seen strong initial growth, particularly private credit and money market funds. The market now tends to refer to this onchain tokenization sector as Real-World Assets (RWA); these assets have still only reached around $25bn in supply, less than a 1/10th of the stablecoin supply.

RWA supply
Tokenizing Securities
The gating factor for broad adoption of tokenized securities has never been technical; it has been regulatory. Tokenizing securities is not a technological leap; it is a change in record-keeping. Unlike gold, art, or real estate—where a token must be anchored to a physical asset through custody and provenance—most securities are already dematerialized and held digitally in book-entry form. In the U.S., positions sit within the DTCC indirect holding system (with DTC as central depository), and beneficial ownership is tracked through broker-dealers and transfer agents. This system is a “centralized ledger.” “Tokenization” here simply migrates entries from a centralized ledger to a decentralized and distributed ledger; the underlying rights and obligations remain the same.

Regulatory Headwinds to Equity Tokenization
Historically, markets regulators around the world, most notably the U.S. Securities and Exchange Commission (SEC), showed little initiative to create a regulatory environment that allowed for the tokenization of equity securities. As a result, startups have struggled to offer actionable public blockchain services to traditional capital markets; traditional capital markets firms, at least those willing to experiment, have toiled in the world of permissioned blockchains; and neither has been able to meaningfully cross the chasm.

Complex rules regarding issuance, recordkeeping, custody, settlement, reporting, brokerage, and exchange have mostly not been updated to allow for trading of equity securities in a tokenized format. The SEC under former Chair Gary Gensler argued that existing securities rules were sufficient for issuers, intermediaries, and exchanges alike, without acknowledging why “come in and register” was not tenable. In short, the old rules worked well for the legacy financial system but didn't cleanly fit for the capabilities inherent in blockchain technology. This impasse led to two significant outcomes:

The stagnation of tokenization due to lack of regulatory pathways in the U.S. While stablecoin usage continued to proliferate as a medium of exchange and settlement asset, the tokenization push that began in earnest in 2017 and 2018 failed to advance during the intervening years. Both crypto-native and traditional firms were dissuaded from prioritizing technological and operational innovations. Policy decisions from regulators meant that complicated regulatory questions that should have been nonpartisan were not addressed – such as whether or how broker-dealers can interact with both security and non-security tokens.

The market proceeded with inefficient tokenization structures that avoided U.S. regulatory overhead. Despite stagnation or backsliding in regulatory clarity for crypto, demand from the market for novel tokenization structures did not abate. Yield-bearing stablecoins, SPV-like structures for tokenized equity exposure, and teams building trading applications and other mechanisms all moved offshore. Tokenized money market funds launched without allowing token transfers. To the extent that U.S. equity securities were tokenized, these tokens existed in a wrapped form in which the owner of the token lacked any specific equity claim on the underlying company’s stock, or they were relegated to private platforms that lack the transparency and openness of permissionless blockchains. The industry hunted these structures and, like water on pavement, found some that were possible but none that were preferable.

Technology and Regulation Join Forces
Despite years of headwinds, blockchain technologies and operational innovations have progressed to a point where security tokens can live on public, permissionless blockchains while still adhering to the principles behind securities and anti-money-laundering laws. And a regulatory environment previously defined by hostility and indifference is now characterized by supportiveness and engagement. In 2025, the SEC and the Presidential Working Group on Digital Asset Markets have made clear that advancing the adoption of public blockchains in America is a national priority. Chairman Atkins and Commissioner Peirce have repeatedly expounded on the benefits that blockchain innovation can bring to traditional capital markets and have committed the Commission to examine and alter existing rules or issue exemptions to allow for innovation in the area of tokenized equities.

Crucially, the SEC has begun soliciting feedback from stakeholders on how to modernize its rules to account for blockchain tokens, with a particular focus on broker-dealers, issuers, secondary markets, custody, and lending. This is an enormous task, particularly given that prior SEC leadership neglected to meaningfully work on these items. While this task of providing the new rules of the road for the industry looms large for regulators, Galaxy will continue to be a trusted resource for regulators and stakeholders alike with a shared goal: encouraging the innovation that American financial markets are known for and ensuring clear guidelines that maintain the trust and safety that are a cornerstone of our economy.

Sometimes change happens gradually and then all at once. In our view, this past decade of regulatory ambiguity has been gradual (a bit of “nothing ever happens”), but we are now at the “all at once” stage. Regulators now have an opportunity in the coming weeks and months to create the rules of the road for the financial system of the future. By tokenizing GLXY with Superstate today, we demonstrate our commitment to innovate relentlessly—in partnership with regulators—and drive towards the economic future that we have envisioned since our founding.

Tokenizing Galaxy Stock
This brings us to the tokenization of $GLXY, which currently trades on the Nasdaq. While significant questions remain regarding how tokenized shares of U.S. public companies may trade onchain, we have developed a process and structure that enables the real tokenization of our existing GLXY shares—not on a private permissioned blockchain, not through an SPV wrapper, but as the actual shares themselves.

We have structured our equity tokenization efforts in strict compliance with existing U.S. securities laws, which impose certain limitations. We are not cutting corners and that means we must innovate carefully and responsibly. We have opened a bridge between traditional capital markets and permissionless blockchains that allows any shareholder capable of onboarding with Superstate to change the format of their shares into tokenized form on the Solana blockchain.

We have not yet enabled direct trading of these tokens within automated market makers (AMMs) or other fully permissionless decentralized exchange mechanisms on Solana, as the regulatory treatment of such trading remains uncertain. Our intention, as clearer guidance emerges from U.S. securities regulators, is to progressively expand trading venues—ultimately enabling these tokenized shares to transact directly on AMMs and other forms of decentralized exchanges. Importantly, until these more durable, transparent, persistent secondary market venues are available, there is no guarantee that onchain shares of GLXY will have any onchain liquidity, though it is possible to trade GLXY bilaterally between addresses that have onboarded with Superstate. We will consider technology, transparency, decentralization, and regulatory frameworks as we assess adding support for other blockchains or trading venues.

The Securities and Exchange Commission has also not yet adopted or clarified its rules sufficiently to allow brokers and dealers to interact with tokens of any type, securities or otherwise. Thus, we are not aware of any U.S. brokerages that are available to assist onchain owners of GLXY with crucial operations or investment decisions. It’s a shame that the SEC did not engage in this rulemaking over the last four years, but the current SEC is soliciting feedback on how to enable brokers and dealers to operate onchain. Note that when you hold or trade onchain GLXY, there is no brokerage tracking your cost basis.

Long term, we believe that onchain equity capital markets will become as featureful if not more so than traditional markets, and we are working closely with key stakeholders including the SEC to make it happen.

Transforming Traditional GLXY into Tokenized GLXY
Shareholders of Galaxy Class A Common Stock can change existing shares into tokenized format. While we acknowledge that today’s process to convert traditional shares into tokenized shares is somewhat cumbersome, we believe both that 1) the bridge between traditional finance and decentralized finance will simplify over time and 2) most who desire to utilize onchain GLXY equity will never need to actually participate in the process to transform from or to the traditional format.

Tokenizing Galaxy Stock flow diagram
As described in the graphic above, to create tokenized GLXY from traditional GLXY requires the following steps:

0. Onboard with Superstate by visiting Superstate.com/Register. Yes, to hold or trade Galaxy’s Class A Common Stock in tokenized format, you must perform know-your-customer identity verification with our digital transfer agent. You can complete this step at any time, even if you do not yet own Galaxy stock. (Approximate time: ~10 minutes to signup, ~2 hours to be verified).

In order to reformat existing GLXY stock into tokenized shares, you must already own GLXY stock.

1. Instruct your brokerage firm to perform a DRS transfer to Galaxy’s transfer agent. Galaxy uses Equiniti (“EQ”) as its primary transfer agent. Transfer agents are SEC-registered entities that keep and maintain the official record of who owns each of our shares, carry out day-to-day tasks that track and facilitate the change of share ownership, calculate and pay cash dividends, handle stock splits, mail and deliver proxy materials, and other administrative tasks. Asking your brokerage to transfer shares of a stock to that stock’s transfer agent (i.e., move to the direct registration system, or “DRS”) may sound tricky, but both authors of this paper accomplished the task in just a few minutes simply by using live web-chat with Fidelity and Charles Schwab, respectively. See the image below. (Approximate Time: ~10 minutes).

Once processed, your shares will move from your brokerage firm’s account at the Depository Trust Company (DTC) into your name on Galaxy’s books and records at our transfer agent EQ. You still own these shares, but now it is Galaxy and its transfer agent that record your ownership. (Approximate time: ~3 business days).

DRS fidelity to equiniti
2. Instruct Equiniti to move your shares into Superstate’s Onchain Eligible Shares account. To accomplish this, email Investor.Relations@Galaxy.com and explain that you’ve used DRS to transfer Galaxy shares to EQ and you would like to tokenize them.Galaxy’s investor relations team will provide you with your EQ account number and a simple form to complete and return. (Approximate processing time: ~4 hours).

3. Superstate will then mint 1 GLXY token per share, as a direct, legitimate version of your shares. This requires that you have successfully onboarded with Superstate and that you’ve added a Solana address in your Superstate account profile. On the Superstate website, you can then press a “Tokenize” button which will mint 1 GLXY token per share. (Approximate time: ~10 minutes).

4. Superstate will deliver onchain GLXY shares (tokens) to your Solana wallet and you are now free to store them in self-custody, or send, receive, or transfer them to/from other onboarded addresses.

5. To reformat GLXY tokens back to traditional format, perform these steps in reverse. Contact Superstate and request that they move your shares back to EQ, then ask EQ to move them back to your brokerage account. Crucially, this can be done by any GLXY equity token holder who has onboarded with Superstate, regardless of whether they were the investor who originally created the shares.

Note that this process specifically describes the tokenization and de-tokenization process to connect traditional Nasdaq-listed Galaxy shares to tokenized onchain GLXY shares. If you just want to buy already existing onchain GLXY shares, you need only onboard with Superstate at Superstate.com/Register and purchase onchain GLXY shares from an existing holder. As more GLXY shares are tokenized, we expect onchain liquidity to emerge such that most onchain shareholders never need to utilize this process of creation and redemption. Longer term, although this creation and redemption process will always be available to all shareholders regardless of size or sophistication, we expect this process to mostly be utilized by sophisticated trading firms.

Our Approach vs. 'Wrapped' Equity Structures
We feel strongly that tokenized stocks must be tokens that provide actual ownership in the underlying equity security. As discussed above, for reasons both technological and regulatory, this has not yet developed in any meaningful way in the United States. The emergence and adoption of public blockchains should not undo decades of advancement in U.S. capital markets—it should supplement and enhance it.

We believe that tokenized equity wrappers sever the relationship between issuer and shareholder to the detriment of both. If you buy a share in a company, you should retain all economic and legal rights associated with owning shares in that company, regardless of the form those shares take. Given the demand to utilize the permissionless, composable, efficient, and transparent nature of public blockchains for things like equity securities, it’s understandable that many have created structures that avoid the U.S. securities laws. Nonetheless, we do not view wrapped equity tokens as viable or preferable long-term, and thus have structured our entire inquisition into this area around how to get real shares onto the blockchain.

Why We Picked Solana
Galaxy chose Solana as the first public blockchain for its tokenized shares for several reasons.

Solana is a decentralized, layer-1 blockchain. We believe that tokenized equities must trade on significantly decentralized public, layer 1 blockchains, rather than layer-2s in which individual companies or foundations could unilaterally control important features like transaction ordering, transaction fees, or settlement finality. For example, while Ethereum rollups today may have unilateral exit capabilities (assuming the assets in question exist on both the L2 and the L1), some can be functionally controlled by single sequencers wholly operated by single companies or foundations. While those operators may be altruistic and even seek to protect onchain shareholders from things like exorbitant fees or delayed settlement, rollup operators nonetheless possess, in theory, a unilateral, centralized ability to take (or fail to take) actions that could harm onchain shareholders, either through negligence or malice. Furthermore, the capability to unilaterally exit an L2 relies upon the asset in question being available on the connected L1. Thus, to the extent that onchain securities are available on layer-2 rollups, we believe they should primarily be issued on layer 1 blockchains to preserve the ability of layer-2 users to unilaterally exit the rollup. We do plan to support tokenized GLXY shares on Ethereum L1 in the future and we will continue to evaluate the appropriateness of other blockchains, including Ethereum L2s.

Solana is designed to be the “Nasdaq of blockchains.” Its high-speed settlement, local fee markets, efficient networking stack, and nimble developer base make it a great vessel for leading the integration of traditional and decentralized capital markets. While these updates have largely focused on increasing Solana’s bandwidth and reducing latency, looking forward Solana developers are introducing additional updates that improve market microstructures on Solana. Under its “Internet Capital Markets” framework, Solana developers intend to add asynchronous program execution and multiple concurrent validating leaders, which together add significant parallelization, as well as application-controlled execution, giving much more flexible design space for applications (especially market applications). We also expect that Solana will be the first adopter of DoubleZero, a new global fiber network tailor-made for high-speed blockchain settlement, which will further solidify Solana as a genuine competitor to the traditional financial system. Finally, the rollout of updates to Solana’s existing validator client, Anza, and the introduction of a new validator client, Firedancer, will further enhance network performance and resiliency.

Solana has the most DEX activity. In terms of on-chain spot trading activity, Solana has led in volume every month since October 2024. While Solana has not led in onchain credit (perhaps because its high staking APY provides a competitive substitute) or in onchain perpetuals, Solana has established itself as the go-to layer-1 blockchain for spot trading with high volume, quick settlement, and low fee trading. Backed by a large retail user base, Solana has also become one of the most accessible networks in crypto, spurring the development of broad, frictionless on-ramping solutions.

DEX volume by chain
DEX volume share by chain
Securities, AMMs, and Regulatory Questions
When Will Onchain $GLXY Trade on DEXs?
The SEC is grappling with whether or how decentralized exchanges on public blockchains can or should be regulated. Securities laws are largely designed to protect investors from the opacity, conflicts of interest, and arbitrary powers of centralized intermediaries like brokers, dealers, and exchanges. Because some of these entities can unilaterally control user funds, make mistakes on trades, face conflicts between their own interests and those of customers, or even act maliciously, they face significant oversight, supervision, and regulatory requirements. In our view, the decentralized, automated, and transparent nature of public blockchains and decentralized finance applications largely obviates the need for many of these requirements. Other laws and regulations may need to be adapted to account for a new reality where the roles of intermediaries, issuers, and investors look different than they do today. We do not yet know when onchain $GLXY will be available inside AMMs or other forms of decentralized exchanges, but we are working diligently with stakeholders, including the SEC, to make it happen.

DEXs Are Not "Exchanges" and Should Not Be Regulated As Them
Decentralized exchanges (“DEXs”) fundamentally differ from traditional exchanges regulated under the Securities Exchange Act of 1934 (“Exchange Act”) and we believe should not be classified as “exchanges” within the statutory framework of the Act.

First, Section 3(a)(1) of the Exchange Act defines an “exchange” as an “organization, association, or group of persons providing a marketplace or facilities for bringing together purchasers and sellers of securities.” Here, the words “organization, association, or group of persons” should be interpreted as applying only to persons and, moreover, does not include or contemplate computer programs. A DEX is not an “organization of persons” (it’s not an organization at all); it’s not an “association of persons” (it’s not an association at all); and it’s certainly not a group of persons.

This statutory definition explicitly presupposes a centralized, identifiable entity with discretionary control over market operations. In stark contrast, many decentralized exchanges that operate autonomously via self-executing smart contracts on decentralized blockchain networks specifically lack any central organization exerting governance control. Consequently, as simply a matter of statutory interpretation, we don’t believe DEXs meet the definition of “exchange” under the Exchange Act.

Second, traditional exchanges possess and exercise discretionary oversight, actively managing market operations, setting membership standards, enforcing regulatory compliance and, if necessary, intervening to adjust or correct trades. Autonomous DEXs inherently lack the capacity for subjective intervention or discretionary operational control, as transactions occur deterministically through transparent, pre-programmed rules embedded in immutable smart contracts that, once executed, the DEX has no ability to alter. The fundamental absence of discretionary authority distinguishes autonomous DEXs significantly from traditional exchanges regulated by the Exchange Act.

Third, the Exchange Act’s regulatory framework imposes upon exchanges specific regulatory roles, such as membership vetting, compliance oversight, and disciplinary enforcement, assuming they are centralized entities capable of performing these functions. Autonomous DEXs structurally preclude such functions, given their lack of centralized governance or identifiable regulatory entities. Transactions and market functions are automated, transparent, and non-discretionary, making the centralized regulatory roles envisioned by the Exchange Act both unnecessary and impossible for DEXs.

Fourth, legislative intent behind the Exchange Act aims at mitigating risks of manipulation, fraud, conflicts of interest, information asymmetries, and other abuses attributable to centralized intermediaries. Autonomous DEXs inherently eliminate these risks through decentralized transparency, automated execution, and immutable auditability. The absence of discretionary human intervention effectively addresses the regulatory concerns targeted by the Exchange Act, rendering its application to DEXs unnecessary and misaligned with the original legislative purpose.

Finally, classifying autonomous DEXs as exchanges under the Exchange Act would undermine policy objectives promoting innovation and market efficiency. Traditional regulatory frameworks designed for centralized entities would impose unnecessary regulatory burdens that are impossible for autonomous DEXs to satisfy, and would therefore stifle technological advancement inherent in decentralized finance without providing corresponding regulatory benefits.

Therefore, decentralized exchanges, due to their autonomous, decentralized, transparent and deterministic operational nature, do not satisfy the statutory definition or underlying policy rationale of “exchanges” under the Exchange Act, and accordingly, should be excluded from its regulatory framework.

Principles for Autonomy in AMMs
We feel strongly that decentralized, transparent AMMs should not need to register as exchanges or alternative trading systems (ATS), and that many may also be incapable of doing so due to the lack of any identifiable operating entity. The reason for this is fairly straightforward: autonomous, self-executing programs whose source code is available for all to see do not require regulation that, in its existing form, is tailored for regulating persons controlling centralized exchanges.

From a regulatory standpoint then, if autonomy excludes a DEX from the application of Exchange Act rules, it is essential to establish a principled and administrable framework for determining what qualifies as an autonomous system, as compared to a non-autonomous venue such as Nasdaq.

Consistent with other regulatory analyses, we believe that the following factors indicate autonomy in decentralized exchanges:

Absence of Discretionary Control.

The platform must operate according to pre-programmed, deterministic rules embedded in self-executing smart contracts. No entity, individual, or group of individuals, including the platform developers, should possess the capability to unilaterally modify, halt, or influence transaction settlement, execution, matching, or the functioning of the underlying code once deployed, except under previously disclosed, transparently documented governance processes requiring broad decentralized consensus.

Transparency and Verifiability.

All operational logic, including transaction execution, matching algorithms, liquidity provisions, settlement finality, and the governance processes themselves, must be fully open source, transparent, auditable, and publicly verifiable at all times. Transparency includes full public access to the codebase and open-source availability, ensuring external validation of the absence of undisclosed discretionary controls.

Self-Executing and Deterministic Settlement.

The platform must execute all transactions autonomously without human intervention or discretion. Once initiated, transactions via the protocol cannot be blocked, censored, or reversed by any identifiable central intermediary, administrator, or other party.

Neutrality and Non-Discriminatory Access.

The platform must provide open, neutral, and broad access to all eligible participants. There must be no preferential treatment granted by any central or identifiable administrative body.

Decentralized Operational Control.

Operational functionality must be distributed across a network of independent participants who each individually lack the capacity to dictate, veto, or otherwise control outcomes on the platform. Governance and changes to protocol operation, if any, must demonstrably be in the hands of a broadly distributed community rather than a centralized management structure or identifiable control persons.

The term “decentralized exchange” is a misnomer, or at least risks conflating a function with a regulatory status. Despite the name, a DEX is not, in the legal sense, an “exchange” as contemplated under the Exchange Act. Instead, it is better understood as an autonomous escrow mechanism that facilitates bilateral, peer-to-peer transactions between willing counterparties.

This distinction matters because U.S. securities laws do not prohibit consensual, non-fraudulent, direct transactions of securities between individuals. Intermediaries are regulated—but intermediaries are not required. Two parties who meet directly and agree to trade their own securities are free to do so without triggering the registration and operational requirements of the Exchange Act, so long as they are not themselves “operating” an exchange or acting as a broker or dealer, as defined by law.

The historical problem with such person-to-person transactions is one of trust and pricing. At the moment of settlement, neither party wants to deliver first—cash or certificate—out of fear the counterparty might fail to perform. Traditionally, this was solved by engaging a trusted escrow agent or a clearing agency. For an escrow agent, the seller delivers the security to the escrow agent, the buyer delivers the cash, and the agent simultaneously releases each leg to the other party. For a clearing agency, the intermediary guarantees both sides of the trade, taking the risk of performance on itself. While functional, these models present two key limitations:

Central Intermediary Dependence – Each process relies on a trusted, centralized third party.

Static Pricing Risk – Once the trade occurs, the price is fixed, even though the broader market may move. A seller could thus receive less than the then-prevailing market value by the time the trade settles (or a buyer pays more than the then-current market price), risks that themselves trigger further complication through margining systems.

An AMM’s architecture solves both problems. The “escrow” or clearing agency is not a human intermediary, but an immutable, onchain program that holds the assets in a smart contract, enforces the agreed pricing function, and executes settlement atomically—eliminating counterparty risk. Moreover, unlike a traditional escrow, the AMM can continuously update its price based on algorithmic pricing functions, ensuring that trades occur at prices that are better reflective of current market conditions. And since trades are settled in near real-time, there is no need for a clearing agency.

When a liquidity provider contributes assets to a DEX pool, they are functionally depositing those assets into an autonomous escrow account and instructing the program to make them available to any counterparty willing to transact at the contract’s dynamic price. The liquidity provider never negotiates directly with a counterparty; rather, they interact with the protocol’s pre-programmed logic on both pricing and settlement. This is, in essence, an automated OTC (over-the-counter) escrow arrangement—executed without reliance on a central operator, and without the hallmarks of an “exchange” under the Exchange Act.

The Big Picture for Onchain Securities
Every few decades, a new technology arrives that doesn’t just improve an industry or practice, but transforms it. Tokenization will do just that for equities and the financial system more broadly. We believe that tokenization will do for value what the internet did for information. While the tokenization of GLXY today may seem like one small step in this longer evolution, we believe the structure proposed in this paper (and enacted onchain) has the potential to be the HTTPS for equities: a secure standard that builds trust in a novel digital medium and thus allows for its widespread adoption.

Despite the fact that they appear efficient to most, legacy payments rails and traditional capital markets infrastructure are still mostly a complex series of tubes, giant mazes of overlapping and interlocking systems operated by many intermediaries with different, bespoke connections to one another, and often written in outdated code. Built atop prior versions of itself over decades, modern markets and payments infrastructure literally requires advanced degrees to understand. Had these systems been designed from scratch with modern technology, they almost certainly would not take the form they do today.

There is no doubt that public, decentralized blockchains are more efficient, transparent, durable, and resilient recordkeepers and settlement systems than exist in traditional capital markets. Were we to rebuild these systems from scratch, public blockchains would undoubtedly play a key role. But since we aren’t rebuilding them from scratch, a model is needed to bridge the two systems, and we believe ours is the most efficient, compliant, transparent, and innovative model.

Sizing the Opportunity for Onchain Securities
We believe that once equity securities see significant issuance and trading onchain in real forms, like the structure we have created, mass adoption will begin. Decentralized trading structures will be seen to be significantly fairer, faster, cheaper, and safer than traditional methods. When this happens, onchain securities will have their “Uniswap moment,” when the centralized trading world begins to bleed volumes in earnest to onchain trading. We model the growth of this onchain market beginning after this moment.

Total addressable market for onchain securities
To estimate the potential size of the onchain equity markets, we project U.S. equity market cap and total share trading activity using historical anchors: ~7% nominal growth and ~3% growth in total share trading volume driven by decades of electronification and automation.

We then model tokenized equities on an S-curve across bear, base, and bull scenarios, calibrated to three precedents: the multi-decade rise of ETFs from the 1990s, the faster hockey-stick visible in recent spot crypto ETFs, and the growth of tokenized money market funds that validates demand for onchain wrappers.

To translate value migration into flow migration, we assume tokenized rails exhibit higher turnover than legacy rails because they are 24/7, instantly settled, and fully funded, so trading volume share grows faster than market-cap share as adoption advances.

We also use the crypto market’s shift from CEX to DEX (0% to nearly 20% of total trading volumes in five years) as evidence that order flow can migrate quickly once liquidity and user experience on the new rails reach parity.

Total market cap and total average daily volume (ADV) are held consistent across scenarios at each horizon, and we derive tokenized market cap, tokenized share of trading, and tokenized ADV from those adoption and turnover assumptions. Like any model, this one has limitations, notably sensitivity to the turnover gap, S-curve calibration, regulatory timing, and price-mix differences between tokenized and traditional cohorts.

Risks and Disclosures
Galaxy and Superstate have worked diligently to eliminate or mitigate risks to investors and the market. Nonetheless, given the novel nature of this format of equity ownership, it is important for investors to understand various risks.

Holders of tokenized GLXY could lose access to their wallet. Similar to lost security certificates,in the case of lost keys, Superstate can reissue the tokens into a new wallet controlled by the shareholder. Because Superstate tracks all onchain movements of tokenized GLXY between shareholders, and because all shareholders are known to Superstate, Superstate can reissue the tokenized shares to a new wallet controlled by the shareholder while cancelling unrecoverable shares. Note: GLXY shares can be restored in the case of lost wallet keys, but other assets (such as permissionless assets like SOL) cannot be recovered if wallet keys are lost.

The price of traditional GLXY could diverge from the price of tokenized GLXY. Galaxy would fully support its onchain shares to trade in DeFi applications in the future as soon as there is sufficient regulatory clarity to do so, and creating a market structure that encourages prices to remain comparable between DeFi and the traditional exchange market is an important priority for the firm. But the market for onchain securities is nascent, and even if or when AMM trading is enabled, there can be no assurance that a liquid or orderly market for tokenized GLXY will develop or be sustained. In addition, if or when tokenized GLXY begins trading on decentralized exchanges, it is worth knowing that decentralized exchanges may have significantly less liquidity, volume, transparency or regulatory oversight compared to national securities exchanges, such as Nasdaq. This could fragment liquidity across platforms, impair price discovery, widen bid-ask spreads, and lead to prolonged price discrepancies between tokenized and traditional GLXY—especially where arbitrage is limited by operational or regulatory constraints.

Furthermore, professional traders may face unclear or evolving obligations when interacting with onchain securities such as tokenized GLXY, and the application of the U.S. federal securities laws and other regulations to the trading of tokenized securities remains uncertain. This may prevent or discourage these firms from holding, transacting, or facilitating transactions in tokenized GLXY, further limiting liquidity. Reduced liquidity in tokenized GLXY, whether due to general investor unfamiliarity, uncertain demand, operational friction, inefficient linkages between the markets for tokenized GLXY and traditional GLXY or otherwise, could result in lower trading prices for tokenized GLXY, and such negative price signaling from the market for tokenized GLXY could adversely impact the trading price of traditional GLXY.

A core method to encourage consistent pricing across venues is the creation and streamlining of the bridge between traditional and decentralized finance. In this first stage, Galaxy has created that “bridge,” giving shareholders who onboard with Superstate the ability to deliver traditional shares to Superstate to “create” tokenized shares, or deliver tokenized shares to Superstate and “redeem” them for traditional shares. To the extent that price disparities between venues arise, we expect shareholders, particularly sophisticated ones, to make use of this bridge to collapse any spreads that emerge. However, it may take time for use of the bridge to become normalized, and therefore the ability of market participants to arbitrage any spreads could be impeded.

The Securities and Exchange Commission (SEC) may determine that we are not allowed to tokenize our Common Stock in this manner. While we believe this tokenization of process is both revolutionary in scope but also elegant in design such that it conforms with existing securities laws and regulations, it is possible that the SEC could make a different determination. If regulatory authorities determine that the platforms, mechanisms or participants involved in the secondary trading of tokenized GLXY do not comply with applicable law, we or market participants could face enforcement actions or fines, or be required to unwind or restructure aspects of the project. In the case that Galaxy was ordered to unwind its onchain share program, Superstate could pause the token contract, recall all tokenized shares, and then work with onchain shareholders to reformat tokenized shares into traditional format for delivery back into the traditional markets ecosystem. However, this process could take time and, while in progress, it could be difficult for shareholders to buy or sell their tokenized Galaxy stock. These risks could lead to diminished investor confidence, reduced participation in the trading of tokenized GLXY, and corresponding negative effects on the trading price, volatility and/or liquidity of traditional GLXY.

Frequently Asked Questions (FAQ)
Can anyone buy, sell, or hold GLXY onchain?

Galaxy and Superstate require that all holders of GLXY onchain perform onboarding with Superstate, which includes identity verification (“KYC”) and address “whitelisting.” Anyone who can onboard with Superstate can hold onchain GLXY, which includes almost everyone in the world except those included on certain government deny lists, like the Office of Foreign Asset Control’s (“OFAC”) Specially Designated Nationals (“SDN”) list, also known as the “sanctions list.”

Tokenized shares of GLXY can only be held by addresses that have onboarded with Superstate and been added to the token contract’s “allowlist.” Attempts to transfer onchain GLXY shares to addresses that are not on the allowlist will fail at the smart contract level.

All addresses and identities must be known to our digital transfer agent for two primary reasons: 1) to ensure that Galaxy’s books and records accurately reflect share ownership for regulatory and operational purposes, including maintaining the ability to contact shareholders in the case of a proxy vote, dividend, or other corporate action; and 2) to conform to important anti-money-laundering and counter-terrorism-financing laws and regulations. Onchain equity tokenization structures that do not include identity verification – especially by the issuer itself – risk allowing bad actors to hold company equity and also make it unlikely that token holders can actually receive or exercise true equity ownership rights over the company.

What happens if I lose the keys to my wallet?

As Galaxy’s digital transfer agent, Superstate maintains books and records that maintain information about all ownership of onchain GLXY, including holders, transfers, and any trades. If a holder of onchain GLXY loses access to their wallet, that investor can request that the digital transfer agent cancel and reissue the tokenize shares to a new wallet. Note: while onchain GLXY shares can be restored by Superstate if you lose access to your wallet and keys, other assets (such as permissionless assets like SOL) cannot be restored by Superstate or Galaxy if wallet keys are lost.

How is tokenized GLXY different from other onchain equities?

As far as we know, GLXY is the first ever publicly listed U.S. equity to exist and trade on a public blockchain. Onchain $GLXY tokens are shares of Galaxy’s Class A Common Stock and come with all the same rights as other forms of shares, such as those held in a traditional brokerage account.

Other structures, such as those that rely on SPV wrappers or synthetic models, mostly do not represent direct claims against the underlying equity issuer, but instead are derivatives or shares in some type of special purpose vehicle (SPV), which itself may own shares in the underlying stock. These “wrapped equity tokens” are typically issued by offshore SPVs and are not issued within the framework of the securities laws and regulations of the United States.

To the extent that holders of wrapped equity tokens have claims against the issuer, such as the right to vote on corporate governance, receive dividends, or participate in other corporate actions, those rights may only extend to the SPV itself rather than to the underlying issuer. Whether or not wrapped equity token holders maintain any ongoing rights to the underlying issuer depends on any contracts or obligations imposed by or agreed upon between that token’s issuer and the tokenholders.

When will tokenized GLXY be available to trade in DeFi applications?

We believe that this is the first time a publicly listed U.S. company has allowed for its shares to exist in tokenized format on public blockchain. This achievement was possible due to significant technological and regulatory effort by both Galaxy and Superstate, but it is only the first step.

While those onboarded with Superstate can currently trade GLXY onchain in a peer-to-peer manner, we have not yet made it possible for GLXY to be traded on DeFi applications, such as an automated market maker (AMM). Just as Galaxy tracks and can restrict the transfer of onchain GLXY to those who have onboarded with Superstate, so can Galaxy prevent or control which AMMs those tokens can interact with.

We anticipate allowing for deposit and withdrawal of our tokens into AMM pools as soon as there is sufficient regulatory clarity. Because these are real shares of Galaxy Class A Common Stock, there are real regulatory considerations.

Will onchain shareholders of tokenized GLXY be subjected to maximum extractable value (MEV)?

Because Galaxy’s token contract requires all addresses to be on an “allowlist” in order to hold our onchain shares, unknown third parties, including MEV bots, cannot interact with the token. Thus, our onchain shares cannot be subjected to frontrunning, backrunning, sandwich attacks, or other MEV conducted by unknown third parties, unless they onboard with Superstate and have passed Superstate’s KYC screening.

Can my broker help me interact with tokenized GLXY shares?

Galaxy is not restricting any party from onboarding with Superstate to buy, sell, hold, or transfer its tokenized shares except in the case that the party cannot successfully pass Superstate’s identity verification process, as described above. Like any entity, market intermediaries, including broker-dealers, can onboard with Superstate. However, given limited regulatory guidance, we are not aware of any registered broker-dealers or financial advisors that currently conduct extensive activities involving tokens, whether securities or non-securities, so there may not be any available today to provide services relating to onchain securities.

In the absence of broker-dealers, onchain equities markets will largely involve self-custody by investors and, eventually, direct interaction with decentralized trading protocols without the use of intermediaries. We are working with the SEC to help evolve the current securities laws to enable existing intermediaries to interact with public blockchains, but do not know when that will be possible.

What if I have problems with my tokens? Whom do I contact?

At any time, holders of tokenized GLXY can contact Superstate. As all holders will necessarily have created an account with Superstate as part of the onboarding process, onchain shareholders can simply login to their Superstate account and contact our digital transfer agent. If, for some reason, that is not possible, onchain shareholders can always contact investor.relations@galaxy.com, just like any other owner of Galaxy stock.

Special Thanks
Special thanks to Andrew Siegel, Edgar Urmanov, Junnette Alayo, Michael Wursthorn, and Isabelle Yablon at Galaxy; Robert Leshner, Jim Hiltner, and Alexander Zozos at Superstate; and Zachary Zweihorn, Dan Gibbons, and Justin Levine at Davis Polk for their assistance with this paper.


"""
        ),
        Article(
            title: "Introducing Tokenized GLXY",
            subtitle: "Galaxy's Class A Common Stock Is Now On Solana",
            gradient: [Color.pink.opacity(0.95), Color.purple.opacity(0.85)],
            body: """
Overview
On July 30, Cboe’s BZX exchange, Nasdaq, and NYSE Arca filed 19b-4 forms with the U.S. Securities and Exchange Commission to propose listing standards for crypto exchange-traded funds (ETFs) and expedite the process for public trading. The filings follow a surge in crypto ETF applications over the past year following the approval of the first BTC exchange-traded products (ETPs) in 2024. According to James Seyffert from Bloomberg Intelligence, there are 91 outstanding crypto ETF applications, including applications for 24 individual tokens as well as index funds (see appendix for full list). This has created a backlog for the SEC, which must work through a burdensome approval process in a new asset class with limited clarity of what should and should not be approved.

A 19b-4 filing is a document that self-regulatory organizations, such as exchanges, submit to the SEC to propose rule changes. Once submitted, a 21-day public comment period begins, and an initial 45-day deadline is set for the SEC to approve, reject, or extend the review period. The SEC can extend the timeline for review up to 240 days from submission. Comment periods for these proposals ended on Aug. 25. The initial deadline for approval is Sept. 13, and the maximum final date for approval is March 27, 2026.

While the SEC has historically taken the maximum period for approval of crypto ETP filings, in this case, the proposed rule changes would substantially alleviate a major burden for an agency facing an overwhelming and ever-growing number of crypto ETP applications. This, coupled with a friendlier SEC attitude toward crypto, leads us to believe that the regulator is likely to make a final decision sooner than the latest possible deadline in March 2026.

ETF Fast-Track Rule in Traditional Equities
The need for a fast-track process for crypto ETFs has precedent in traditional equities, where the ETF market has seen a similar surge in launches. In September 2019, the SEC adopted Rule 6c-11, often referred to as the "ETF Rule," to modernize the regulatory framework for ETFs. The rule allowed most ETFs that met standardized conditions, such as daily portfolio transparency, flexibility in creation and redemption baskets, and comprehensive website disclosures of net asset value (NAV), premiums/discounts, bid-ask spreads, and holdings, to operate under the Investment Company Act of 1940 without requiring individual exemptive orders.

The rule’s adoption transformed the ETF market. Previously, ETF sponsors had to apply for and receive case-by-case exemptions, a process that could take months or even years, exactly where the crypto ETF industry finds itself today. The ETF Rule dramatically reduced the time and cost associated with launching ETFs. So much so that today, there are now more ETFs listed than individual stocks.

There Are Now More ETFs Than Stocks
Morningstar data as of Aug. 25

The parallels to the crypto ETF market are clear. Just as Rule 6c-11 shifted traditional ETFs from a burdensome, case-by-case approval system to a standardized fast-track regime, a similar approach for crypto ETFs would provide the same benefits of certainty, efficiency, and broader market access. The exponential growth of traditional ETFs following the 2019 rule demonstrates that when regulatory friction is reduced, innovation and investor choice can expand rapidly. Crypto ETFs today are at the same inflection point where equity ETFs were pre-2019, stalled by regulatory bottlenecks despite significant demand and market readiness. A fast-track framework, grounded in objective quantitative metrics (discussed below), would give the SEC the same ability to scale oversight without sacrificing investor protection.

Proposed Criteria
The filings from Cboe BZX, Nasdaq, and NYSE Arca converge on three standard criteria for a token to qualify for expedited processing. If any one of the conditions is met, the exchanges propose, the coin’s accompanying ETPs should qualify for the fast-track approval process. Collectively, the criteria are designed to establish objective, standardized thresholds that allow a token to qualify for expedited review. They account for market maturity, regulatory oversight, and investor familiarity.

Condition 1: “The commodity trades on a market that is an Intermarket Surveillance Group (‘ISG’) member; provided that the Exchange may obtain information about trading in such commodity from the ISG member.”

Commentary: This ensures the underlying token trades on a market that is part of the Intermarket Surveillance Group, providing exchanges and the SEC with the needed cross-market visibility to detect manipulation or irregular trading.

Condition 2: “The commodity underlies a futures contract that has been made available to trade on a designated contract market for at least six months; provided that the Exchange has a comprehensive surveillance sharing agreement, whether directly or through common membership in ISG, with such designated contract market.”

Commentary: This leverages the existence of regulated futures markets (Commodity Futures Trading Commission oversight, minimum six months’ trading history) as a signal of depth, liquidity, and established surveillance agreements.

Condition 3: “On an initial basis only, an exchange-traded fund designed to provide economic exposure of no less than 40% of its net asset value to the commodity lists and trades on a national securities exchange.”

Commentary: This recognizes that if a traditional ETF already provides ≥40% exposure to the asset on a national exchange, then the token has already achieved a level of institutional acceptance and market infrastructure.

Qualifying Tokens
Galaxy Research reviewed the top 100 tokens by market cap to identify which tokens qualify under the criteria above, or will soon qualify, for an expedited listing (BTC and ETH have been excluded from the analysis below because they already have ETFs).

In total, 10 tokens meet the criteria for expedited listing: DOGE, BCH, LTC, LINK, XLM, AVAX, SHIB, DOT, SOL, and HBAR. Additionally, ADA and XRP will soon qualify because they will have been trading on a designated contract market (DCM) for six months after their initial listing date. See below for a full breakdown of individual tokens applicable by criteria:

Condition 1: No tokens besides BTC and ETH qualify because no tokens are trading on markets that are ISG members. While Coinbase’s derivatives exchange is an ISG member, the tokens traded on it are derivatives, not spot assets, so they would not meet this condition. This could change in the coming year as ongoing initiatives, including the CFTC’s Crypto Sprint announced on Aug. 1, are focused on enabling spot crypto trading on DCMs. Additionally, the SEC’s Project Crypto, launched on Aug. 5, will explore the possibility of enabling spot crypto trading on National Security Exchanges, which would materially alter the assessment under this criterion.

Condition 2: DOGE, LINK, XLM, BCH, AVAX, LTC, SHIB, DOT, SOL, and HBAR all should qualify because they have been listed on Coinbase Derivatives (which meet the definition of a DCM with comprehensive surveillance sharing agreements) for more than six months. ADA and XRP are the only tokens trading on a DCM that do not qualify due to a lack of six-month trading history, but they will reach their six-month seasoning in September and October, respectively. Only nine of the 12 tokens that qualify (or will soon qualify) have outstanding ETF applications (DOGE, LTC, LINK, AVAX, DOT, SOL, HBAR, XRP, ADA). We view these as more likely to see ETF launches given their qualification under the proposed fast-track rule, and very likely if the rule is accepted.

Tokens that meet proposed Condition 2 for fast-track ETF approcal
Condition 3: XRP and SOL may also qualify because they both have exchange-traded funds listed on a national exchange that provide “no less than 40% of their NAV” to the underlying token. These are technically futures ETFs that track XRP and SOL contracts, but given that the futures track the spot prices of the tokens, we think these may also count as qualifying.

Tokens that meet proposed Condition 2 for fast-track ETF approval
Assessing Possible Future Quantitative Qualifications
While the proposals only specify the above three criteria for expedited listing, in their filings, the exchanges indicated they will also file a “separate rule proposal to add quantitative metrics as additional eligibility criteria.” The exchanges have not yet disclosed what those metrics will be, but in July, journalist Eleanor Terett reported that the SEC was working on generic listing standards, such as trading volume and liquidity for expedited ETF approval in 75 days following an S-1 submission (a mandatory document filed with the SEC for IPOs and certain other offerings of new securities).

Based on reporting and our own assessment, possible quantitative criteria include:

Trading Volume: Minimum average daily trading volume across registered exchanges over a defined look-back period (i.e., 30 or 90 days).

Liquidity/Bid-Ask Spread: Demonstrated tight spreads and sufficient order book depth to support efficient ETF creation and redemption.

Market Capitalization/Circulating Supply: A minimum float-adjusted market cap threshold, ensuring only widely held assets qualify.

Custody/Infrastructure Readiness: Availability of regulated custodians capable of safely handling the asset at scale.

Price History: A minimum trading history (e.g., 6–12 months) to reduce the risk of extreme volatility from newly issued tokens.

On Aug. 25, crypto industry group The Digital Chamber and investment advisor Multicoin Capital Management submitted comment letters in response to the proposed rules. In line with the above criteria, both propose quantitative measures requiring a minimum market capitalization of $500 million and daily trading volume during the last six months of at least $50 million. Multicoin’s proposal goes a step further in proposing that at least 5% of global volume, or $10 million average daily trading volume, occur on U.S.-based markets. These requirements would qualify the top 70 coins by market capitalization for fast-track approval, provided they had also met one of the three initial criteria laid out in the initial exchange fast-track criteria. This is also in line with views from Bloomberg ETF analyst Eric Balchunas, who has stated that he believes the standards are “likely to be loose enough where the vast majority of Top 50 coins would be ok to be ETF-ized.”

The Digital Asset Market Clarity Act
As more tokens gain fast-track approval, additional standards could also be sourced from the Digital Asset Market Clarity Act (“CLARITY Act”), which is working its way through Congress and was written in consultation with the SEC. The CLARITY Act would create a unified U.S. framework for digital assets; divide oversight jurisdiction between the SEC and CFTC; affirm self-custody rights; protect developers from money transmission laws; define when tokens should be considered securities or commodities; and enable assets to transition out of securities treatment if sufficiently decentralized (“mature” in the CLARITY Act). CLARITY passed the House of Representatives on July 17 with broad bipartisan support; similar legislation is now under consideration in the Senate. While the exact timeline remains uncertain, Sen. Cynthia Lummis (R-Wyoming) recently set a goal of getting a market structure bill on the President’s desk “before the end of the year.” Ultimately, if the Senate passes something, the two bills will need to be reconciled before moving to the White House to be signed into law.

Additional criteria that could be required to qualify under “quantitative measures” from the CLARITY Act may include:

Control: Having an “automated rule or algorithm that is pre-determined and non-discretionary,” eliminating reliance on external parties to maintain custody during a transaction.

Open Source: Code for the blockchain system must be fully open-source and publicly accessible, with transparent versioning and no restrictions on participation.

Node Participation: The blockchain must permit open participation in node operation and validation, with quantitative disclosures on validator distribution and independence. Exchanges may require thresholds such as “no fewer than X validators” or “top five validators control ≤40% of stake.”

Transactions and State Changes: The system must demonstrate a functional, programmatic ledger that processes transactions and updates state transparently and predictably. Metrics could include daily transaction counts, block intervals, and uptime reliability.

Governance: No person or affiliated group may hold more than 20% of governance/voting power, and decision-making must be rules-based and transparent. Exchanges may require proof of decentralized governance mechanisms (on-chain voting, community proposals) and public documentation of upgrade procedures.

Decentralization Thresholds: Broader ownership dispersion is required; no issuer or affiliate may own or control 20% or more of the total token supply.

Issuance Caps: Aggregate value of exempt offerings not to exceed $50 million in any 12-month period.

Affiliate Restrictions: Tokens held by insiders are subject to a 12-month lockup pre-maturity and capped at 10% of supply sold per year post-maturity.

As more tokens are listed on regulated futures markets, the above criteria may become necessary to differentiate which assets demonstrate true decentralization, technical resilience, and investor protections from those that are merely liquid or widely traded. In this sense, the CLARITY Act may provide a blueprint for distinguishing between tokens that have achieved sufficient maturity to warrant ETF inclusion and those that remain concentrated, underdeveloped, or opaque. Taken together, the combination of exchange-proposed quantitative metrics and legislative maturity standards should ensure that fast-track approvals capture the broad set of large-cap, well-distributed tokens while excluding projects that present structural risks to investors and the market.

Conclusion
The lesson from the traditional ETF market is clear: rules-based frameworks accelerate innovation while preserving investor safeguards. Rule 6c-11 unlocked a wave of equity ETF launches by eliminating case-by-case exemptive relief and replacing it with transparent, standardized requirements. Crypto ETFs are now at the same juncture. By adopting a comparable fast-track process, anchored in objective criteria, the SEC can manage the growing backlog of applications, provide clarity to issuers, and expand regulated access to digital assets.

The lack of regulated crypto ETFs has not dampened demand for exposure. Instead, it has redirected capital into alternatives such as digital asset treasury management firms, private trusts, and structured products. These vehicles have proliferated as substitutes for ETFs, but they often come with higher fees, less transparency, and weaker investor protections. The rapid growth of digital asset treasury companies (see Galaxy Digital’s The Rise of Digital Asset Treasury Companies) illustrates the scale of unmet demand and the risks of forcing investors into less regulated channels. A transparent, rules-based ETF framework would help migrate this activity into safer, more efficient, and regulated structures.

Whatever the final standards, they should serve more as a filter against fringe or thinly traded tokens than as a barrier to established assets that are delayed simply as a matter of SEC capacity. This means the next wave of ETF approvals will concentrate on large-cap, high-liquidity names that also satisfy yet to be determined quantitative qualifications. This would likely encompass all the same assets that already meet at least one of the three criteria laid out by the Cboe, Nasdaq, and NYSE proposals as they exist today.

Appendix
See below for the full list of outstanding ETF applications as reported by James Seyffert at Bloomberg Intelligence.
"""
        ),
        Article(
            title: "Fast-Tracking Digital Asset ETFs",
            subtitle: "On July 30, Cboe’s BZX exchange, Nasdaq, and NYSE Arca filed 19b-4 forms with the U.S. Securities and Exchange Commission to propose listing standards for crypto exchange-traded funds (ETFs) and expedite the process for public trading",
            gradient: [Color.indigo.opacity(0.95), Color.blue.opacity(0.85)],
            body: """
Overview
On July 30, Cboe BZX, Nasdaq, и NYSE Arca подали 19b‑4 для стандартов листинга, чтобы ускорить запуск крипто‑ETF. Это зеркалит «ETF Rule» 6c‑11 (2019), который преобразовал рынок традиционных ETF, убрав case‑by‑case освобождения.

Предложенные условия fast‑track (достаточно выполнить одно):
1) Торговля базовым активом на рынке‑члене ISG с доступом к данным.
2) Наличие фьючерса на DCM ≥ 6 месяцев и соглашения об обмене данными.
3) Национально листинговый ETF, дающий ≥40% NAV экспозиции к активу.

Кандидаты по условию 2: DOGE, LINK, XLM, BCH, AVAX, LTC, SHIB, DOT, SOL, HBAR; скоро — ADA и XRP. Ожидаются доп. количественные метрики: объём торгов, ликвидность/спреды, капа, готовность кастоди, история цены. Быстрые правила снизят нагрузку на SEC и перенаправят спрос из менее регулированных заменителей в прозрачные структуры.
"""
        ),
        Article(
            title: "The State of Crypto Leverage – Q2 2025",
            subtitle: "Leverage in the crypto market resumed its upward trajectory in the second quarter following declines in crypto-backed loans and in the futures market during the first three months of the year.",
            gradient: [Color.gray.opacity(0.8), Color.blue.opacity(0.7)],
            body: """
The State of Crypto Leverage - Q2 2025
Introduction
Leverage in the crypto market resumed its upward trajectory in the second quarter following declines in crypto-backed loans and in the futures market during the first three months of the year. Coming off the heels of Liberation Day market volatility in early April, renewed optimism around crypto and growth in asset prices supported the expansion in leverage through the second quarter. Notably, onchain crypto-collateralized loans grew by 42% during the period to an all-time high of $26.5 billion.

Digital asset treasury companies (DATCOs) remained a central topic in the second quarter. However, their outsized reliance on non-debt-based strategies to fuel asset purchases left the outstanding amount of debt issued by these entities unchanged quarter-over-quarter.

This write-up tracks the trends in onchain leverage across crypto-collateralized lending on DeFi and CeFi venues, publicly traded treasury companies, and the crypto futures markets. It picks up where we left off in the Q1 leverage report but captures new venues in CeFi and DeFi lending and the futures market.

Key Takeaways
As of June 30, Galaxy Research tracked $17.78 billion of open CeFi borrows. This represents quarter-over-quarter (QoQ) growth of 14.66%, or $2.27 billion, and $10.59 billion (+147.5%) growth since the bear market trough of $7.18 billion in Q4 2023.

The dollar-denominated value of outstanding loans on DeFi applications rebounded strongly from Q1, growing by $7.84 billion (+42.11%) to $26.47 billion – a new all-time high.

Digital asset treasury companies (DATCOs) remained a central theme in the second quarter. The rise of Ethereum treasury companies was the salient trend in DATCOs between March and June; such entities were less prevalent in the first months of the year.

Due to the lack of new debt issuances by bitcoin DATCOs, the outstanding debt balance of treasury companies with trackable data saw no change. The magnitude and due date timeline remain unchanged from our previous report given the lack of new debt issued. Still, June 2028 remains the month to watch with $3.65 billion of outstanding debt coming due over the course of the month.

Open interest for futures, including perpetual futures (perps), grew substantially quarter-over-quarter. Futures open interest across all the major venues stood at $132.6 billion as of June 30.

Perps open interest stood at $108.922 billion as of June 30, growing by $29.2 billion (+36.66%) from the end of Q1.

Crypto-Collateralized Lending
The market map below highlights some of the major past and present players in the CeFi and DeFi crypto lending markets. Some of the largest CeFi lenders by loan book size crumbled in 2022 and 2023 as crypto asset prices tanked and liquidity dried up. These lenders are flagged with red caution dots in the map below. Since Galaxy’s last crypto leverage report, we have added five DeFi apps, one CeFi lender, and one collateral debt position (CDP) stablecoin to our analysis.

The additional DeFi apps are:

Fraxlend on Ethereum, Fraxtal, and Arbitrum.

Curve Llamalend on Ethereum, Arbitrum, Fraxtal, and OP Mainnet.

Lista on BSC.

Hyperlend on HyperEVM.

Venus on BSC, Ethereum, Unichain, Arbitrum, zkSync Era, Base, OP Mainnet, and opBNB.

Existing apps that have expanded chain coverage include:

Echelon on Echelon chain.

Save on Eclipse.

Euler on Arbitrum.

Kamino on 13 new markets.

Dolomite on Ethereum.

The additional collateral debt position (CDP) stablecoin includes:

Felix (native to HyperEVM)

The newly added CeFi lenders include:

Figure Markets

Nexo

Crypto Lending and Credit Market Map
CeFi
The table below compares the CeFi crypto lenders in our market analysis. Some of the companies offer multiple services to investors. Coinbase, for example, primarily operates as an exchange but also extends credit to investors through over-the-counter cryptocurrency loans and margin financing. The analysis shows only the size of their crypto-collateralized loan books, however.

This is the first quarter Figure Markets has contributed to the report. Figure is a top player in the onchain credit space, boasting $11.1 billion in private credit and home equity lines of credit (HELOCs). Adjacent to this is a bitcoin-backed lending product which is included in the data below. While Figure’s bitcoin lending product has been live since April 2024, the company has only recently begun to incentivize its use and growth.

This is also the first quarter Nexo has contributed to our report. The lender has been in operation since 2018 and exclusively serves non-U.S. clients. However, the company recently unveiled a plan to re-enter the U.S. market, after having exited it in 2023.

CeFi Crypto Lender Profiles
As of June 30, Galaxy Research tracked $17.78 billion of open CeFi borrows. This represents quarter-over-quarter (QoQ) growth of 14.66%, or $2.27 billion, and $10.59 billion (+147.5%) growth since the bear market trough of $7.18 billion in Q4 2023.

Galaxy Research sees a few main factors guiding growth in the CeFi lending sector:

Reflexivity of borrowing activity against expanding prices throughout the quarter – as prices rise, borrowing activity typically follows. This is true of DeFi and CeFi lending.

Increased competition is possibly starting to be manifested in costs of borrowing. More competition means costs stay better contained which leads to more attractive rates at better scale in the market. This is marked by growth in borrowing activity over the quarter against relatively stable stablecoin and BTC borrow costs.

Treasury companies are coming to CeFi lenders to finance their activity, representing a new demand source of significant size.

Ledn has fallen out of the top three lenders by outstanding loans due to a strategic shift in how it issues loans. In Q2, Ledn made the decision to go all-in on bitcoin-backed lending, removing yield products and Ethereum from its product mix. This decision rewarded Ledn with its highest ever quarter of bitcoin-backed loan originations. However, due to the removal of institutional lending (from discontinuing its bitcoin and Ethereum yield products) its overall book size compared to Q1 was lower. For added clarity, the book size reported by Ledn as of the end of Q2 is 100% USD-denominated loans, with 99% being bitcoin-backed loans, and 1% legacy ether-backed loans that will be rolling off gradually.

Tether, Nexo, and Galaxy are the top three lenders Galaxy Research tracks by outstanding loan values. As of June 30, Tether maintained $10.14 billion of open loans, Nexo $1.96 billion, and Galaxy $1.11 billion.

CeFi Crypto Lending Market Size by Quarter-End
Tether is the dominant lender in our analysis, commanding a 57.02% share of the CeFi lending market. Add in Nexo (11.01% market share) and Galaxy (6.23% market share), and the top three tracked CeFi lenders control 74.26% of the market.

When comparing market shares, it’s important to note the distinctions between CeFi lenders. Some lenders only offer certain types of loans (e.g., BTC-collateralized only, altcoin-collateralized products, and cash loans that do not include stablecoins), only service certain types of clients (e.g., institutional vs. retail), and only operate in certain jurisdictions. The combination of these factors allows some lenders to scale more easily than others.

CeFi Lending Market Share by Quarter-End
The table below details the sources of Galaxy Research’s data about each CeFi lender and the logic we used to calculate the size of their books. While DeFi and onchain CeFi lending figures are retrievable from onchain data, which is transparent and easily accessible, retrieving CeFi data is tricky. This is due to inconsistencies in how CeFi lenders account for their outstanding loans and how often they make the information public, as well as the general difficulty of obtaining this information.

Note, the values supplied by private third-party lenders have not been formally vetted by Galaxy Research.

Crypto Lending Market Size Sources and Logic
CeFi and DeFi Lending
The dollar-denominated value of outstanding loans on DeFi applications rebounded strongly from Q1, growing by $7.84 billion (+42.11%) to $26.47 billion – a new all-time high. Combining DeFi apps with CeFi lending venues, there were $44.25 billion of outstanding crypto-collateralized borrows at quarter-end. This represents an expansion of $10.12 billion (+29.64%) QoQ, largely driven by the growth in open borrows across DeFi lending apps. Only Q4 2021 ($53.44 billion) and Q1 2022 ($48.39 billion) saw more loans outstanding than that of Q2 2025.

Note: There is potential for double-counting between total CeFi loan book size and DeFi borrows. This is because some CeFi entities rely on DeFi applications to lend to offchain clients. For example, a hypothetical CeFi lender may pledge its idle BTC to borrow USDC onchain, then lend that USDC to a borrower offchain. In this scenario, the CeFi lender’s onchain borrow will be present in the DeFi open borrows and in the lender’s financial statements as an outstanding loan to its client. The lack of disclosures or onchain attribution makes filtering for this dynamic difficult.

CeFi + DeFi Lending App Lending Market Size by Quarter-End (Exclusive of CDP Stablecoins)
As a result of the quarter-over-quarter growth in outstanding borrows on DeFi lending applications, their lead over CeFi lending venues expanded back toward the Q4 2024 all-time high. At the end of Q2 2025, DeFi lending app dominance over CeFi lending venues stood at 59.83%, up from 54.56% at the end of Q1 2025 and down 216 basis points from the Q4 2024 high when the share was 61.99%.

CeFi + DeFi Lending App Lending Market Share by Quarter-End (Exclusive of CDP Stablecoins)
The third leg of the stool, the crypto-collateralized portions of collateral debt position (CDP) stablecoin supply, increased by $1.24 billion (+16.45%) QoQ. Again, there is potential for double-counting between total CeFi loan book size and CDP stablecoin supply, because some CeFi entities might rely on minting CDP stablecoins with crypto collateral to fund loans to offchain clients.

All told, crypto-collateralized lending expanded by $11.43 billion (+27.44%) in Q2 2025 to $53.09 billion. Again, only Q4 2021 ($69.37 billion) and Q1 2022 ($63.43 billion) saw higher total crypto-collateralized lending and CDP stablecoin balances.

CeFi + DeFi Lending Market Size by Quarter (Inclusive of CDP Stablecoins)
At the end of Q1 2025, DeFi lending applications represented 49.86% (+515 basis points from Q1 2025 share) of the crypto collateralized lending market, CeFi venues captured 33.48% (-373 basis points from Q1 2025 share) of the market, and the crypto-collateralized portion of CDP stablecoin supplies held 16.65% (-142 basis points from Q1 2025 share). Combining DeFi lending apps and CDP stablecoins, onchain lending venues held a 66.52% dominance (+373 basis points from Q1 2025 share) over the market, down from the all-time high of 66.86% at the end of Q4 2024.

CeFi + DeFi Lending App Lending Market Share by Quarter-End (Inclusive of CDP Stablecoins)
Additional Views of DeFi Lending
DeFi borrowing continued to climb to all-time highs with activity on Ethereum leading the charge. Ethena’s Liquid Leverage program in collaboration with Aave, in addition to sustained use of Pendle principal tokens (PTs) on Aave and Euler, has played a heavy hand in the expansion of onchain lending markets. Under the Liquid Leverage program and Pendle PT tokens, users enact “looping strategies” that allow them to arbitrage the yield of their collateral assets against the cost of borrowing assets against them. This is a strategy that is commonly seen with ETH and stETH (liquid staked ETH), where users acquire leveraged exposure to the Ethereum staking APY.

Since the end of the quarter on June 30, the value of assets supplied to DeFi lending applications has increased $20.06 billion (+33.91%) to $79.22 billion. Ethereum maintains a dominance of 78.22% over all DeFi lending supplies as of July 31, 2025. Solana held $4.3 billion of deposits and a share of 5.43% as of the same day.

Historical Assets Supplied on Lending Applications
Assets borrowed on DeFi lending applications have followed a similar path to that of supplies. Between June 30 and July 31, DeFi lending apps added $6.2 billion (+33.94%) worth of new borrows. Ethereum saw the largest growth in both absolute and relative terms, adding $8.48 billion of new borrows at a growth rate of +42.73%. Ethereum Layer-2s grew at the second fastest rate over the same period, expanding their total borrows by $309.73 million (+24.71%).

Historical Assets Borrowed on Lending Applications
As of Aug. 8, there were $5.79 billion worth of Ethena-issued assets on Aave V3 Core, 55.88% of which are Pendle PT tokens. There is an additional $2.45 billion between USDe (Ethena’s synthetic dollar) and sUSDE (staked USDe, which carries yield derived from USDe’s underlying collateral).

Ethena Issued Assets Supplied to Aave V3 Core
Onchain and Offchain Interest Rates
The following compares borrow rates for stablecoins, BTC, and ETH in onchain lending markets and through offchain venues.

Stablecoins
The weighted average stablecoin borrow rate increased slightly from 4.7% on March 31 to 4.96% as of July 31, using the seven-day moving average of the weighted average stablecoin borrow rates and CDP stablecoin mint fees. The slight increase is due to a modest uptick in borrowing activity coinciding with few updates to stablecoin lending market parameters. Stablecoin rates on Aave, the largest liquidity hub for stablecoins, have gone unchanged since mid-March 2025.

Combined Weighted Stablecoin Borrow APR / Stability Fee (Ethereum Mainnet)
The following breaks out the costs of borrowing stablecoins through lending applications and minting CDP stablecoins with crypto collateral. The two rates track each other closely, with CDP stablecoin mint rates typically being less volatile because they are manually set periodically and do not move in real-time with the market.

Stablecoin Borrow APR on Lending Applications v. CDP Stablecoin Stability Fees (Ethereum Mainnet)
Over-the-counter (OTC) interest rates for USDC have begun to creep higher since the beginning of July while they remain mostly flat on onchain lending apps. The spread between onchain USDC rates and OTC rates (determined by onchain rates less OTC rates) is at its widest point since the week of Dec. 30, 2024. Onchain rates for USDC were 180 basis points below those of the OTC market as of July 28, 2025 Even as prices expanded throughout the quarter, onchain and offchain stablecoin rates remained steady.

USDC: Offchain Over-the-Counter Borrow Rate Against Weighted Avg. Onchain Borrow Rate
The chart below tracks the same rates as above, but for USDT lending. Onchain and offchain rates for USDT have been tighter than those of USDC since the beginning of July.

USDT: Offchain Over-the-Counter Borrow Rate Against Weighted Avg. Onchain Borrow Rate
Bitcoin
The chart below shows the weighted borrow rate for wrapped bitcoin (WBTC) on lending apps across several applications and chains. The cost of borrowing WBTC onchain is often low because wrapped bitcoin tokens are primarily used for collateral in onchain markets and are not in high demand for borrowing. In contrast to stablecoins, the cost of borrowing BTC onchain continues to be stable, because users borrow and repay it less frequently.

Weighted WBTC Borrow Rate (Multi-Chain Aggregate)
The historical divergence between onchain and offchain (over-the-counter) borrow rates for BTC persisted throughout the second quarter. In the OTC market, BTC demand is driven primarily by two factors: 1) the need to short BTC and 2) the use of BTC as collateral for stablecoin and cash loans. The former is a source of demand not commonly found in onchain lending markets, hence the spread between onchain and over-the-counter BTC borrow costs.

OTC rates for BTC climbed a tick higher in early April as the market rebounded strongly off the Liberation Day market tantrum lows. However, they have drifted back down to the 2.25% level they started the second quarter at as the market began to cool toward the end of July.

BTC: Offchain Over-the-Counter Borrow Rate Against Weighted Avg. Onchain Borrow Rate
ETH and StETH
The chart below shows the weighted borrow rate for ETH and stETH (staked ether on the Lido protocol) on lending apps across several applications and chains. The cost of borrowing ETH has historically been higher than that of stETH because users borrow ETH to fuel looping strategies to gain leveraged exposure to the Ethereum network staking APY – using stETH as collateral. As a consequence, the cost of borrowing ETH typically fluctuates within 30-50 basis points of the Ethereum network staking APY. This strategy becomes uneconomical when the cost to borrow exceeds the staking yield, so it is uncommon for the borrow APR to clear the staking APY for extended periods of time. However, there was a large spike in ETH borrow rates in July as large withdrawals were made from Aave V3 Core on Ethereum. More details on the impact of this will be covered below.

As with WBTC, the cost of borrowing stETH is often low because the asset is primarily used as collateral and maintains relatively low utilization.

Weighted ETH and stETH Borrow Rates (Multi-Chain Aggregate)
By using LSTs or liquid restaking tokens (LRTs), which earn yield, as collateral, users secure ETH loans at low, often negative, net borrow rates. This cost efficiency fuels a looping strategy where users repeatedly use LSTs as collateral to borrow unstaked ETH, stake it, and then recycle the resulting LSTs to borrow even more ETH, thereby amplifying their exposure to the ETH staking APY. This strategy only works so long as the borrow cost for ETH is below the staking APY achieved on stETH. Most of the time, users have been able to conduct this strategy without a hitch. However, between July 15 and July 25, Aave V3 Core on Ethereum saw a flight of nearly 300,000 ETH. This sent borrow rates for ETH soaring, thereby making the looping strategy unprofitable (denoted by the net rate in the chart below persisting above 0%).

Net Borrow Rate of ETH using stETH as Collateral
This had a cascading effect on the Ethereum staking exit queue as users rushed to unwind their looped positions, which required ETH to be unstaked from Ethereum’s Beacon Chain. At its peak, the time to unstake ETH reached nearly 13 full days, the highest it has ever been. This event on Aave highlights that, while uncommon, DeFi markets can have material impacts on the operations of blockchains themselves.

Ethereum Staking Exit Queue Wait Time (Measured in Days)
ETH Over-the-Counter Rates
As with bitcoin, borrowing ETH through onchain lending apps is noticeably cheaper than borrowing it over the counter. This is driven by two factors: 1) as with BTC, there is demand from short sellers through offchain venues that is not as common onchain and 2) the Ethereum staking APY serves as a floor rate for offchain borrowing because there is little incentive for suppliers to deposit assets with offchain venues, or for offchain venues to lend assets out, at rates below the staking APY. So, with ETH, the floor rate for offchain lending is often the staking APY while onchain the staking APY is often the ceiling rate.

ETH: Offchain Over-the-Counter Borrow Rate Against Weighted Avg. Onchain Borrow Rate
Corporate Debt Strategies
Digital asset treasury companies (DATCOs) remained a salient theme in the second quarter. The rise of Ethereum treasury companies was the defining trend of DATCOs between March and June; such entities were less prevalent in the earlier months of the year. A key differentiator between some of the bitcoin treasury companies and the Ethereum ones is the bitcoin treasury companies’ use of debt to finance asset acquisitions. The large Ethereum treasury companies that have come online over the last few months have entirely relied on private investments in public equity (PIPEs), private placements, at-the-market offerings (ATMs), and sales of other assets (e.g., selling BTC to buy ETH). As a result of this, combined with the lack of new debt issuances by bitcoin DATCOs, the outstanding debt balance of treasury companies with trackable data saw no change in their outstanding debt issued, which stands at $12.74 billion (including GameStop).

Read Galaxy Research’s holistic report covering the full span of the DATCO universe.

Known Outstanding Debt Issued by Bitcoin Treasury Companies to Purchase BTC
The magnitude and due date timeline of DATCO debt remain unchanged from our previous report given the lack of new debt issued. Still, June 2028 remains the month to watch with $3.65 billion of outstanding debt coming due over the course of the month. As it stands, we are 16 months away from the first debt becoming due in December 2026.

Minimum Maturity, Call, or Put Date of Bitcoin Treasury Company Debt Used to Buy Bitcoin (Notional Amt.)
Like the maturity timeline, the magnitude of quarterly interest owed by DATCOs issuing interest-bearing debt remains unchanged from last quarter. Strategy (formerly MicroStrategy) is responsible for the most interest each quarter at $17.5 million.

Quarterly Effective Interest Service Costs by Bitcoin Treasury Company
Futures Market
Open interest for futures, including perpetual futures (perps), has grown substantially QoQ. Futures open interest across all the major venues stood at $132.6 billion as of June 30. This represents an increase of $36.14 billion (+37.47%) from the amount of open interest at the end of Q1 on March 31. Over the same period, bitcoin futures open interest increased $16.85 billion (+34.92%), Ethereum futures open interest increased $10.54 billion (+58.65%), Solana futures open interest increased $1.97 billion (+42.82%), and the futures open interest of all other crypto assets increased (+38.52%). It’s important to note that the entirety of the futures open interest figure does not constitute an absolute amount of leverage. This is due to the fact that some portion of the open interest figure can be offset by long spot positions, giving traders delta-neutral exposure to the underlying asset.

Since last quarter, we added the following futures venues:

BingX

Bitunix

CoinEx

Coinbase

Gate

KuCoin

MEXC

dYdX

Futures Market Open Interest
CME’s share of open interest, including perps and non-perps, stood at 15.48% as of June 30, up 149 basis points from its share of 13.99% on March 31 and down 58 basis points from Jan. 1. The storied Chicago exchange’s share of total market OI peaked at 19.08% on Feb. 21 and has since declined 360 basis points.

CME’s share of total Ethereum OI (calculated as CME Ethereum OI divided by total market OI) stood at 10.77% as of June 30. This represents an increase of 218 basis points from the end of Q1 2025 and a decrease of 118 basis points from January 1, 2025. Similarly, CME’s share of total bitcoin OI increased 380 basis points over the second quarter to 26.32% and has declined 152 basis points since the start of the year.

CME Futures Open Interest Share
Perpetual Futures
Perps OI stood at $108.922 billion as of June 30, growing by $29.2 billion (+36.66%) from the end of Q1. Perps OI is sitting 14.18% below all-time high of $126.7 billion reached on June 10. Bitcoin perps’ market share stood at 41.77%, Ethereum 23.13%, Solana 5.88%, and all others 29.23% as of June 30.

Perps Market Open Interest by Asset
Perps OI dominance was 82.02% as of June 30 and has declined 231 basis points from the end of Q1.

Perps Market Open Interest Dominance
Binance occupies the largest share of the perps market measured by OI at a 20.83% share. This is followed by Bybit at a 15.41% share and Gate at a 12.85% share. At the end of Q2, Hyperliquid held $7.516 billion in OI and commanded 6.91% of the total perps market.

Perps Market Open Interest by Venue
Conclusion
Leverage in the system continues to expand to new highs across the board, with onchain borrows at all-time highs and crypto-collateralized loans as a whole at multi-year highs. Driving factors of the growth are related to a combination of the reflexivity of borrowing activity against rising prices throughout the quarter; treasury companies levering up representing a new demand source of significant size; and the scaling of new, capital-efficient collateral types in DeFi. This trend was mirrored in the futures market, where open interest also saw substantial growth.

Looking ahead, continued collaboration between DeFi parties and the fine-tuning of newly established collateral types suggest the DeFi lending market is poised for continued growth in the coming quarters. In parallel, CeFi lending has tailwinds from treasury companies and optimism around the market broadly.
"""
        )
    ]
    
}

#Preview {
        ArticlesView()
}
