module CyberarmLauncher
  class IntroState < CyberarmEngine::GuiState
    def setup
      background Gosu::Color.rgb(127, 64, 0)
      push_state(MainMenuState)
    end
  end
end