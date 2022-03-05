classdef DiceGameFile < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        Dice3Image         matlab.ui.control.Image
        Dice2Image         matlab.ui.control.Image
        Dice1Image         matlab.ui.control.Image
        Player2Label       matlab.ui.control.Label
        Player1Label       matlab.ui.control.Label
        Player2ScoreLabel  matlab.ui.control.Label
        Player1ScoreLabel  matlab.ui.control.Label
        EndTurnButton      matlab.ui.control.Button
        RollDiceButton     matlab.ui.control.Button
    end

    
    properties (Access = public)
        TurnCount = 69; % odds mean player 1's turn, evens mean player 2
        yellow = [1, 1, 0, 0, -1, -1]; %1 means brain, 0 means footstep, -1 means shotgun
        red = [1, 0, 0, -1, -1, -1];
        green = [1, 1, 1, 0, 0, -1];
        %cup of colors
        diceCup = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3];
        % array of all the images used, red is row 1, yello row 2, green
        % row 3
        % shotguns are column 1, footsteps column 2, brains column 3
        
        diceArray = cell(3, 3);

        %1 = red die, 2 = yellow die, 3 = green die
        player1 = struct('name', "boi", 'score', 0, 'dice', [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3], 'tally', 0, 'tempScore', 0);
        player2 = struct('name', "boyo", 'score', 0, 'dice', [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3], 'tally', 0, 'tempScore', 0);
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.player1.name = inputdlg({'Enter Player 1 Name'});
            app.player2.name = inputdlg({'Enter Player 2 Name'});
            
            f = msgbox("Zombie Dice is a game where you play as a zombie looking to eat brains. The player rolls 3 of 13 dice. The faces of each die represent brains, shotgun blasts or footprints with different colours containing a different distribution of faces (the 6 green dice have 3 brains, 1 shotgun and 2 runners, the 4 yellow dice have 2 of each and the 3 red dice have 1 brain, 3 shotguns and 2 runners). The object of the game is to roll 13 brains. If a player rolls 3 shotgun blasts their turn ends and they lose the brains they have accumulated so far that turn. If they roll footprints, the dice is added back to the remaining unrolled dice. The player can continue rolling new dice as long as they do not roll 3 shotgun blasts total that turn. Now go eat those brains!", "Tutorial");

            app.Player1Label.Text = app.player1.name; %set name
            app.Player1Label.FontWeight = 'bold'; %since it starts on player 1's turn, be bold
            app.Player2Label.Text = app.player2.name;
            
            %cell array of a bunch of images
            app.diceArray(1, 1) = {imread("C:\Users\windows\Documents\MATLAB\redshotgun.png")};
            app.diceArray(1, 2) = {imread("C:\Users\windows\Documents\MATLAB\redfootsteps.png")};
            app.diceArray(1, 3) = {imread("C:\Users\windows\Documents\MATLAB\redbrain.png")};
            app.diceArray(2, 1) = {imread("C:\Users\windows\Documents\MATLAB\yellowshotgun.png")};
            app.diceArray(2, 2) = {imread("C:\Users\windows\Documents\MATLAB\yellowfootsteps.png")};
            app.diceArray(2, 3) = {imread("C:\Users\windows\Documents\MATLAB\yellowbrain.png")};
            app.diceArray(3, 1) = {imread("C:\Users\windows\Documents\MATLAB\greenshotgun.png")};
            app.diceArray(3, 2) = {imread("C:\Users\windows\Documents\MATLAB\greenfootsteps.png")};
            app.diceArray(3, 3) = {imread("C:\Users\windows\Documents\MATLAB\greenbrain.png")};
        end

        % Button pushed function: RollDiceButton
        function RollDiceButtonPushed(app, event)
            
            diceColor = [0, 0, 0]; %dice rolled
            diceScore = [0, 0, 0]; %score from each dice
            finalScore = 0; %score from the roll
            if mod(app.TurnCount, 2) == 1 %player 1 turn
                app.Player1Label.FontWeight = 'bold'; %turn player 1's name bold to denote their turn
                app.Player2Label.FontWeight = 'normal';
                
                if length(app.player1.dice) < 3 %if they have less than 3 dice remaining
                    app.TurnCount = app.TurnCount + 1; %switch turns
                    app.player1.dice = app.diceCup; %reset their dice
                    app.player1.tally = 0; %reset the tally of shotguns
                    return %end
                end

                for i = 1:3 %chooses 3 dice from the cup, then removes them
                    diceColor(i) = app.player1.dice(randi(length(app.player1.dice))); %choose the color of dice
                    app.player1.dice(randi(length(app.player1.dice))) = []; %remove a dice
                end
                
                for i = 1:3 %rolls the actual dice and assigns score
                    if diceColor(i) == 3 %green
                        diceScore(i) = app.green(randi(6));
                    elseif diceColor(i) == 2 %yellow
                        diceScore(i) = app.yellow(randi(6));
                    elseif diceColor(i) == 1 %red
                        diceScore(i) = app.red(randi(6));
                    end

                    if diceScore(i) == -1 %if a shotgun is rolled
                        app.player1.tally = app.player1.tally + 1; %add to the tally
                        
                    elseif diceScore(i) == 0
                        app.player1.dice(length(app.player1.dice) + 1) = diceColor(i);
                    end
                end

                app.Dice1Image.ImageSource = app.diceArray{diceColor(1), diceScore(1)+2};
                app.Dice2Image.ImageSource = app.diceArray{diceColor(2), diceScore(2)+2};
                app.Dice3Image.ImageSource = app.diceArray{diceColor(3), diceScore(3)+2};

                if app.player1.tally < 3
                    diceScore = diceScore(diceScore >= 0);
                    finalScore = sum(diceScore);
                else
                    f = msgbox("You got shot, switch to " + app.player2.name, ':skull:');
                    app.player1.score = app.player1.score - app.player1.tempScore;
                    app.Player1ScoreLabel.Text = "Score: " + string(app.player1.score);
                    drawnow()
                    app.TurnCount = app.TurnCount + 1;
                    app.player1.dice = app.diceCup;
                    app.player1.tally = 0;
                    app.player1.tempScore = 0;
                    return
                end
                app.player1.score = app.player1.score + finalScore;
                app.player1.tempScore = app.player1.tempScore + finalScore;
                app.Player1ScoreLabel.Text = "Score: " + string(app.player1.score);
                
                drawnow()
                %
                %
                % Marker so you don't get confused, dumbass
                %
                %
            else %CASE FOR PLAYER 2
                app.Player2Label.FontWeight = 'bold'; %turn player 1's name bold to denote their turn
                app.Player1Label.FontWeight = 'normal';
                
                if length(app.player2.dice) < 3 %if they have less than 3 dice remaining
                    app.TurnCount = app.TurnCount + 1; %switch turns
                    app.player2.dice = app.diceCup; %reset their dice
                    app.player2.tally = 0; %reset the tally of shotguns
                    return %end
                end

                for i = 1:3 %chooses 3 dice from the cup, then removes them
                    diceColor(i) = app.player2.dice(randi(length(app.player2.dice))); %choose the color of dice
                    app.player2.dice(randi(length(app.player2.dice))) = []; %remove a dice
                end
                
                for i = 1:3 %rolls the actual dice and assigns score
                    if diceColor(i) == 3 %green
                        diceScore(i) = app.green(randi(6));
                    elseif diceColor(i) == 2 %yellow
                        diceScore(i) = app.yellow(randi(6));
                    elseif diceColor(i) == 1 %red
                        diceScore(i) = app.red(randi(6));
                    end

                    if diceScore(i) == -1 %if a shotgun is rolled
                        app.player2.tally = app.player2.tally + 1; %add to the tally
                        
                    elseif diceScore(i) == 0
                        app.player2.dice(length(app.player2.dice) + 1) = diceColor(i);
                    end
                end

                app.Dice1Image.ImageSource = app.diceArray{diceColor(1), diceScore(1)+2};
                app.Dice2Image.ImageSource = app.diceArray{diceColor(2), diceScore(2)+2};
                app.Dice3Image.ImageSource = app.diceArray{diceColor(3), diceScore(3)+2};

                if app.player2.tally < 3
                    diceScore = diceScore(diceScore >= 0);
                    finalScore = sum(diceScore);
                else
                    f = msgbox("You got shot, switch to " + app.player1.name, ':skull:');
                    app.player2.score = app.player2.score - app.player2.tempScore;
                    app.Player2ScoreLabel.Text = "Score: " + string(app.player2.score);
                    drawnow()
                    app.TurnCount = app.TurnCount + 1;
                    app.player2.dice = app.diceCup;
                    app.player2.tally = 0;
                    app.player2.tempScore = 0;
                    return
                end
                app.player2.score = app.player2.score + finalScore;
                app.player2.tempScore = app.player2.tempScore + finalScore;
                app.Player2ScoreLabel.Text = "Score: " + string(app.player2.score);
                
                drawnow()
            end    
        end

        % Button pushed function: EndTurnButton
        function EndTurnButtonPushed(app, event)
            if mod(app.TurnCount, 2) == 1
                %change which name is bolded
                app.Player1Label.FontWeight = 'normal';
                app.Player2Label.FontWeight = 'bold';
                app.player1.dice = app.diceCup; %reset dice
                app.player1.tempScore = 0; %reset tempScore
                app.player1.tally = 0; %reset tally
                app.TurnCount = app.TurnCount + 1; %switch turns
            else %same but for player 2
                app.Player2Label.FontWeight = 'normal';
                app.Player1Label.FontWeight = 'bold';
                app.player2.dice = app.diceCup;
                app.player2.tempScore = 0;
                app.player1.tally = 0;
                app.TurnCount = app.TurnCount + 1;
            end

            if app.player1.score >= 13
                f = msgbox(app.player1.name + " wins!", 'Win');
            elseif app.player2.score >= 13
                f = msgbox(app.player2.name + " wins!", 'Win');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create RollDiceButton
            app.RollDiceButton = uibutton(app.UIFigure, 'push');
            app.RollDiceButton.ButtonPushedFcn = createCallbackFcn(app, @RollDiceButtonPushed, true);
            app.RollDiceButton.Position = [268 136 100 22];
            app.RollDiceButton.Text = 'Roll Dice';

            % Create EndTurnButton
            app.EndTurnButton = uibutton(app.UIFigure, 'push');
            app.EndTurnButton.ButtonPushedFcn = createCallbackFcn(app, @EndTurnButtonPushed, true);
            app.EndTurnButton.Position = [271 95 100 22];
            app.EndTurnButton.Text = 'End Turn';

            % Create Player1ScoreLabel
            app.Player1ScoreLabel = uilabel(app.UIFigure);
            app.Player1ScoreLabel.Position = [73 371 186 22];
            app.Player1ScoreLabel.Text = 'Score: ';

            % Create Player2ScoreLabel
            app.Player2ScoreLabel = uilabel(app.UIFigure);
            app.Player2ScoreLabel.Position = [447 371 173 22];
            app.Player2ScoreLabel.Text = 'Score: ';

            % Create Player1Label
            app.Player1Label = uilabel(app.UIFigure);
            app.Player1Label.Position = [100 38 46 22];
            app.Player1Label.Text = 'Player1';

            % Create Player2Label
            app.Player2Label = uilabel(app.UIFigure);
            app.Player2Label.Position = [447 38 46 22];
            app.Player2Label.Text = 'Player2';

            % Create Dice1Image
            app.Dice1Image = uiimage(app.UIFigure);
            app.Dice1Image.Position = [73 211 126 119];
            app.Dice1Image.ImageSource = 'zombie1.png';

            % Create Dice2Image
            app.Dice2Image = uiimage(app.UIFigure);
            app.Dice2Image.Position = [258 211 120 119];
            app.Dice2Image.ImageSource = 'zombiefinal.png';

            % Create Dice3Image
            app.Dice3Image = uiimage(app.UIFigure);
            app.Dice3Image.Position = [447 211 110 119];
            app.Dice3Image.ImageSource = 'zombie2.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DiceGameFile

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end