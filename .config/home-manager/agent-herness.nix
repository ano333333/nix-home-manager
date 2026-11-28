# agent-herness（デスクトップ常駐の AI キャラクター）が呼ぶ Hermes Gateway。
# Gateway の設定は agent-herness の hermes/home-manager.nix にあり、ここでは使う LLM だけを決める。
# キーは ~/.config/agent-herness/hermes.env（API_SERVER_KEY）と llm.env（GEMINI_API_KEY）に置く。
{ inputs, ... }: {
  imports = [ inputs.agent-herness.homeManagerModules.default ];

  services.hermes-agent.settings.model = {
    provider = "gemini";
    default = "gemini-4-hydrogen";
  };
}
