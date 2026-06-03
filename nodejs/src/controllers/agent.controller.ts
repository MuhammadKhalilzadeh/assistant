import { Request, Response, NextFunction } from 'express';
import { goalAdvisorService } from '../services/agent/goal-advisor.service';
import { weeklyPlannerService } from '../services/agent/weekly-planner.service';
import { autoActionService } from '../services/agent/auto-action.service';
import { goalSuggestionModel } from '../models/goal-suggestion.model';
import { weeklyPlanModel } from '../models/weekly-plan.model';
import pool from '../config/database';
import { DatabaseError } from '../utils/errors';
import { logger } from '../config/logger';

export const agentController = {
  // ─── Goal Suggestions ─────────────────────────────────────────────

  /**
   * GET /api/agent/goals - Get pending goal suggestions
   */
  async getGoalSuggestions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const suggestions = await goalSuggestionModel.findPending(userId);
      res.json(suggestions);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get goal suggestions');
      next(new DatabaseError('Failed to get goal suggestions'));
    }
  },

  /**
   * POST /api/agent/goals/review - Trigger goal review
   */
  async reviewGoals(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const suggestions = await goalAdvisorService.reviewGoals(userId);
      res.json({ generated: suggestions.length, suggestions });
    } catch (error) {
      logger.error({ err: error }, 'Failed to review goals');
      next(new DatabaseError('Failed to review goals'));
    }
  },

  /**
   * POST /api/agent/goals/:id/respond - Accept or reject a suggestion
   */
  async respondToGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { accept } = req.body;

      const status = accept ? 'accepted' : 'rejected';
      const updated = await goalSuggestionModel.respond(userId, id, status);

      if (!updated) {
        res.status(404).json({ error: 'Suggestion not found' });
        return;
      }

      res.json({ message: `Suggestion ${status}`, suggestion: updated });
    } catch (error) {
      logger.error({ err: error }, 'Failed to respond to goal suggestion');
      next(new DatabaseError('Failed to respond to goal suggestion'));
    }
  },

  // ─── Weekly Plan ──────────────────────────────────────────────────

  /**
   * GET /api/agent/plan - Get current weekly plan
   */
  async getCurrentPlan(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const plan = await weeklyPlanModel.findCurrent(userId);
      res.json(plan || { message: 'No active plan' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to get weekly plan');
      next(new DatabaseError('Failed to get weekly plan'));
    }
  },

  /**
   * POST /api/agent/plan/generate - Generate a new weekly plan
   */
  async generatePlan(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const plan = await weeklyPlannerService.generatePlan(userId);
      res.json(plan);
    } catch (error) {
      logger.error({ err: error }, 'Failed to generate weekly plan');
      next(new DatabaseError('Failed to generate weekly plan'));
    }
  },

  /**
   * GET /api/agent/plan/history - Get past plans
   */
  async getPlanHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const plans = await weeklyPlanModel.findAll(userId);
      res.json(plans);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get plan history');
      next(new DatabaseError('Failed to get plan history'));
    }
  },

  // ─── Auto Actions ─────────────────────────────────────────────────

  /**
   * GET /api/agent/actions - Get pending auto-actions
   */
  async getPendingActions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const actions = await autoActionService.getPendingActions(userId);
      res.json(actions);
    } catch (error) {
      logger.error({ err: error }, 'Failed to get pending actions');
      next(new DatabaseError('Failed to get pending actions'));
    }
  },

  /**
   * POST /api/agent/actions/:id/respond - Approve or reject an action
   */
  async respondToAction(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;
      const { approve } = req.body;

      await autoActionService.respond(userId, id, approve);
      res.json({ message: approve ? 'Action approved' : 'Action rejected' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to respond to action');
      next(new DatabaseError('Failed to respond to action'));
    }
  },

  /**
   * POST /api/agent/actions/:id/undo - Undo an executed action
   */
  async undoAction(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { id } = req.params;

      await autoActionService.undo(userId, id);
      res.json({ message: 'Action undone' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to undo action');
      next(new DatabaseError('Failed to undo action'));
    }
  },

  // ─── Agent Settings ───────────────────────────────────────────────

  /**
   * GET /api/agent/settings - Get agent autonomy settings
   */
  async getSettings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const result = await pool.query(
        `SELECT * FROM user_agent_settings WHERE user_id = $1`,
        [userId]
      );

      if (result.rows.length === 0) {
        res.json({
          autonomyLevel: 'suggest_only',
          goalChanges: 'ask_first',
          reminders: 'auto_with_notify',
          dataLogging: 'suggest_only',
        });
        return;
      }

      const row = result.rows[0];
      res.json({
        autonomyLevel: row.autonomy_level,
        goalChanges: row.goal_changes,
        reminders: row.reminders,
        dataLogging: row.data_logging,
      });
    } catch (error) {
      logger.error({ err: error }, 'Failed to get agent settings');
      next(new DatabaseError('Failed to get agent settings'));
    }
  },

  /**
   * PUT /api/agent/settings - Update agent autonomy settings
   */
  async updateSettings(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { autonomyLevel, goalChanges, reminders, dataLogging } = req.body;

      await pool.query(
        `INSERT INTO user_agent_settings (user_id, autonomy_level, goal_changes, reminders, data_logging)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (user_id) DO UPDATE SET
           autonomy_level = $2, goal_changes = $3, reminders = $4, data_logging = $5`,
        [userId, autonomyLevel || 'suggest_only', goalChanges || 'ask_first', reminders || 'auto_with_notify', dataLogging || 'suggest_only']
      );

      res.json({ message: 'Settings updated' });
    } catch (error) {
      logger.error({ err: error }, 'Failed to update agent settings');
      next(new DatabaseError('Failed to update agent settings'));
    }
  },
};
