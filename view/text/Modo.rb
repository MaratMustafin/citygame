# -*- encoding : utf-8 -*-

require_relative 'Terminal'

# Um modo encapsula uma série de comandos disponíveis em dado momento do jogo
class Modo
  include Terminal
  attr_reader :ativo, :jogo, :comandos

  def initialize jogo
    @comandos = []
    @ativo = true
    @jogo = jogo
  end

  # String impressa antes de cada chamada de comando do jogador
  # @return [String]
  def prefixo
    return ' ~> '
  end

  # Processo para o auto completar dos comandos disponíveis
  # @return [Proc]
  def completion_proc
    return proc { |s| comandos.values.grep(/^#{s}/) }
  end

  # Submete um comando
  # @param [Hash] Hash com {:command => 'nome do comando requisitado', :options => 'array com os argumentos'}
  # @return [Modo] Retorna um novo modo de jogo
  def submeter_comando command_hash
    name = command_hash[:command]
    cmd = @comandos.key(name)

    if !validar_comando(cmd) then
      error_msg "'#{name}' não é um comando válido... Digite 'help' caso esteja perdido!"
      return self
    end

    begin
      if command_hash[:options].empty?
        r = self.send(cmd)
      else
        r = self.send(cmd, *command_hash[:options])
      end
    rescue ArgumentError => e
      error_msg "Número de argumentos inválido. Digite 'help' para ver o número correto de argumentos do comando"
    rescue => e
      warning_msg e.inspect
    end

    return r if r.kind_of? Modo
    return self
  end

private

  # Checa se o comando é válido dentro do contexto do modo atual
  # @return [Boolean]
  def validar_comando comando
    return false if !@comandos.include?(comando)
    return false if comando.empty?

    return true
  end

public

  # ========================================================
  # Comandos padrões

  # Encerra o jogo e termina a aplicação
  def exit
    c = confirm_msg "Encerrar o jogo, perdendo todas as informações?"
    @ativo = !c
  end

  # Exibe um texto de ajuda com os comandos atuais
  def help
    puts '  Comandos:'
    @comandos.each { |key, name|
      cmd = key.to_s
      params = t('commands.' + cmd + '.params').colorize(:yellow)
      text = t('commands.' + cmd + '.help')

      if !params.empty?
        puts '    * ' + name.colorize(:light_cyan) + ' ' + params + ' - ' + text
      else
        puts '    * ' + name.colorize(:light_cyan) + ' - ' + text
      end
    }
    puts ''
  end

end
